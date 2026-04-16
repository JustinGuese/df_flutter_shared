import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'chat_config.dart';
import 'models/chat.dart';

class ChatRepository {
  ChatRepository(this._dio, {this.config = const ChatConfig()});

  final Dio _dio;
  final ChatConfig config;

  String? _pendingFormattedContent;
  String? get pendingFormattedContent => _pendingFormattedContent;

  /// Resolves [path] against [config.basePath], if provided, and replaces
  /// `{chatId}` placeholders with the numeric [chatId].
  String _resolvePath(String path, {int? chatId}) {
    var resolved = path;
    if (chatId != null) {
      resolved = resolved.replaceAll('{chatId}', chatId.toString());
    }

    final base = config.basePath;
    if (base == null || base.isEmpty) {
      return resolved;
    }

    if (resolved.isEmpty || resolved == '/') {
      return base;
    }

    if (resolved.startsWith('/')) {
      return '$base$resolved';
    }

    return '$base/$resolved';
  }

  Future<Chat> getChat() async {
    final response = await _dio.get<Map<String, dynamic>>(
      _resolvePath(config.chatEndpoint),
    );
    return Chat.fromJson(response.data!);
  }

  Future<List<Message>> getMessages(
    int chatId, {
    int skip = 0,
    int? limit,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      _resolvePath(config.messagesEndpoint, chatId: chatId),
      queryParameters: {
        'skip': skip,
        'limit': limit ?? config.defaultPageSize,
      },
    );
    final data = response.data ?? [];
    return data
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Send a message and return the bot's [Message] response.
  Future<Message> sendMessage(int chatId, String content) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _resolvePath(config.messagesEndpoint, chatId: chatId),
      queryParameters: {'content': content},
    );
    return Message.fromJson(response.data!);
  }

  Future<void> resetChat(int chatId) async {
    await _dio.delete<void>(
      _resolvePath(config.resetEndpoint, chatId: chatId),
    );
  }

  Stream<String> streamMessage(int chatId, String content) async* {
    _pendingFormattedContent = null;
    final streamEndpoint = config.streamEndpoint;
    if (streamEndpoint == null || streamEndpoint.isEmpty) {
      throw StateError(
        'streamEndpoint is not configured; use sendMessageSync for non-streaming chats.',
      );
    }

    final response = await _dio.post(
      _resolvePath(streamEndpoint, chatId: chatId),
      queryParameters: {'content': content},
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    final responseBody = response.data;
    if (responseBody is! ResponseBody) {
      throw Exception('Expected ResponseBody for streaming response');
    }

    final lines = responseBody.stream
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .transform(const LineSplitter());

    String? currentEvent;
    String? currentData;

    await for (final line in lines) {
      if (line.isEmpty) {
        // SSE message separator — process accumulated event+data
        final hasEvent = currentEvent != null;
        final hasData = currentData != null;

        if (hasData) {
          // Resolve event type: prefer explicit event line, then fall back to
          // the "type" field inside the JSON data (for backends that omit
          // the SSE event line and embed the type in the payload).
          String? resolvedEvent = currentEvent;
          Map<String, dynamic>? jsonData;

          try {
            final decoded = jsonDecode(currentData);
            if (decoded is Map<String, dynamic>) {
              jsonData = decoded;
              final jsonType = jsonData['type'];
              if (jsonType is String) {
                resolvedEvent = jsonType;
              }
            }
            // If decoded is a List (e.g. sources event), leave jsonData null
            // and keep resolvedEvent as-is so it falls through to the
            // "unknown event" / silent-ignore path below.
          } catch (_) {
            // Not JSON or unexpected shape — resolvedEvent stays as currentEvent
          }

          if (resolvedEvent == 'token') {
            final tokenContent = jsonData?['content'] as String?;
            if (tokenContent != null && tokenContent.isNotEmpty) {
              yield tokenContent;
            } else if (jsonData == null && currentData.isNotEmpty) {
              // Plain-text token (non-JSON data with event: token)
              yield currentData;
            }
          } else if (resolvedEvent == 'error') {
            final errorContent =
                jsonData?['content'] as String? ?? currentData;
            throw Exception(errorContent);
          } else if (resolvedEvent == 'message_saved') {
            _pendingFormattedContent = jsonData?['content'] as String?;
          } else if (resolvedEvent == 'end') {
            break;
          } else if (resolvedEvent == null && currentData.isNotEmpty) {
            // No event name and non-JSON plain text — best-effort: treat as token
            yield currentData;
          }
          // Unknown events (sources, etc.) — silently ignored
        } else if (hasEvent && currentEvent == 'end') {
          // event: end with no data line
          break;
        }

        currentEvent = null;
        currentData = null;
      } else if (line.startsWith('event: ')) {
        currentEvent = line.substring(7).trim();
      } else if (line.startsWith('data: ')) {
        // SSE spec: strip exactly one leading space after "data:" — already
        // handled by substring(6). Do NOT trim further; leading spaces in the
        // value are intentional word-separator characters from the backend.
        final dataLine = line.substring(6);
        if (currentData == null) {
          currentData = dataLine;
        } else {
          currentData += '\n$dataLine';
        }
      }
    }
  }
}
