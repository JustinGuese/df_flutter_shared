import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'chat_config.dart';
import 'models/chat.dart';

class ChatRepository {
  ChatRepository(this._dio, {this.config = const ChatConfig()});

  final Dio _dio;
  final ChatConfig config;

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

  /// Legacy single-message send used as a fallback by [ChatController].
  Future<Message> sendMessage(int chatId, String content) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _resolvePath(config.messagesEndpoint, chatId: chatId),
      data: {'content': content},
    );
    return Message.fromJson(response.data!);
  }

  /// Non-streaming send that returns a full user/bot [MessagePair].
  ///
  /// This is used when [ChatConfig.streamEndpoint] is null or empty.
  Future<MessagePair> sendMessageSync(int chatId, String content) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _resolvePath(config.messagesEndpoint, chatId: chatId),
      data: {'content': content},
    );
    return MessagePair.fromJson(response.data!);
  }

  Future<void> resetChat(int chatId) async {
    await _dio.delete<void>(
      _resolvePath(config.resetEndpoint, chatId: chatId),
    );
  }

  Stream<String> streamMessage(int chatId, String content) async* {
    final streamEndpoint = config.streamEndpoint;
    if (streamEndpoint == null || streamEndpoint.isEmpty) {
      throw StateError(
        'streamEndpoint is not configured; use sendMessageSync for non-streaming chats.',
      );
    }

    final response = await _dio.post(
      _resolvePath(streamEndpoint, chatId: chatId),
      data: {'content': content},
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
        if (currentEvent != null && currentData != null) {
          try {
            final jsonData = jsonDecode(currentData) as Map<String, dynamic>;
            final jsonEventType = jsonData['type'];
            final eventType =
                jsonEventType is String ? jsonEventType : currentEvent;

            if (eventType == 'token') {
              final tokenContent = jsonData['content'] as String?;
              if (tokenContent != null && tokenContent.isNotEmpty) {
                yield tokenContent;
              }
            } else if (eventType == 'error') {
              final errorContent =
                  jsonData['content'] as String? ?? currentData;
              throw Exception(errorContent);
            } else if (eventType == 'end') {
              break;
            }
          } catch (e) {
            if (currentEvent == 'token' && currentData.isNotEmpty) {
              yield currentData;
            } else if (currentEvent == 'end') {
              break;
            } else if (currentEvent == 'error') {
              throw Exception(currentData);
            }
          }
          currentEvent = null;
          currentData = null;
        } else if (currentEvent == 'end') {
          break;
        }
      } else if (line.startsWith('event: ')) {
        currentEvent = line.substring(7).trim();
      } else if (line.startsWith('data: ')) {
        final dataLine = line.substring(6).trim();
        if (currentData == null) {
          currentData = dataLine;
        } else {
          currentData += '\n$dataLine';
        }
      }
    }
  }
}
