import 'dart:async';
import 'dart:ui';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_config.dart';
import 'chat_repository.dart';
import 'models/chat.dart';

class ChatState {
  ChatState({
    required this.messages,
    required this.isLoading,
    required this.isStreaming,
    this.chat,
    this.error,
  });

  final List<types.Message> messages;
  final bool isLoading;
  final bool isStreaming;
  final Chat? chat;
  final String? error;

  ChatState copyWith({
    List<types.Message>? messages,
    bool? isLoading,
    bool? isStreaming,
    Chat? chat,
    Object? error = _sentinel,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      chat: chat ?? this.chat,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

final chatConfigProvider = Provider<ChatConfig>((ref) {
  return const ChatConfig();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  throw UnimplementedError(
      'Must be overridden - provide your Dio client and ChatRepository');
});

final chatProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ChatController extends Notifier<ChatState> {
  StreamSubscription<String>? _streamSubscription;
  int? _streamingMessageIndex;
  int _localMessageCounter = 0;

  /// Called when a message is sent (streaming or fallback). Wire from app for analytics.
  VoidCallback? onMessageSent;

  @override
  ChatState build() {
    return ChatState(
      messages: [],
      isLoading: false,
      isStreaming: false,
    );
  }

  int get _defaultPageSize =>
      ref.read(chatConfigProvider).defaultPageSize;

  String get _streamingPlaceholderText =>
      ref.read(chatConfigProvider).streamingPlaceholderText;

  bool get _hasStreamingEndpoint {
    final endpoint = ref.read(chatConfigProvider).streamEndpoint;
    return endpoint != null && endpoint.isNotEmpty;
  }

  types.User get currentUser => types.User(
        id: currentUserId,
        firstName: ref.read(chatConfigProvider).currentUserName,
      );

  types.User get botUser => types.User(
        id: botUserId,
        firstName: ref.read(chatConfigProvider).botUserName,
      );

  static const String currentUserId = '1';
  static const String botUserId = '2';

  Future<void> initializeChat() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final repository = ref.read(chatRepositoryProvider);
      final chat = await repository.getChat();

      final messages = await repository.getMessages(
        chat.id!,
        skip: 0,
        limit: _defaultPageSize,
      );

      final chatMessages =
          messages.map((m) => _messageToChatMessage(m)).toList();

      chatMessages.sort(
        (a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0),
      );

      state = state.copyWith(
        chat: chat,
        messages: chatMessages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    if (state.chat?.id == null) {
      await initializeChat();
      if (state.chat?.id == null) {
        return;
      }
    }

    final chatId = state.chat!.id!;
    final repository = ref.read(chatRepositoryProvider);

    final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
    _localMessageCounter++;
    final userMessage = types.TextMessage(
      id: 'local_user_${baseTimestamp}_$_localMessageCounter',
      author: currentUser,
      createdAt: baseTimestamp,
      text: content,
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
    );

    if (_hasStreamingEndpoint) {
      try {
        state = state.copyWith(isStreaming: true, error: null);

        _localMessageCounter++;
        final botMessageId = 'local_bot_${baseTimestamp}_$_localMessageCounter';
        final botMessage = types.TextMessage(
          id: botMessageId,
          author: botUser,
          createdAt: baseTimestamp + 1,
          text: _streamingPlaceholderText,
        );
        final botMessageIndex = state.messages.length;
        state = state.copyWith(
          messages: [...state.messages, botMessage],
        );
        _streamingMessageIndex = botMessageIndex;

        _streamSubscription?.cancel();
        _streamSubscription = repository.streamMessage(chatId, content).listen(
          (token) {
            final currentMessages = List<types.Message>.from(state.messages);
            if (_streamingMessageIndex != null &&
                _streamingMessageIndex! < currentMessages.length) {
              final existingMessage = currentMessages[_streamingMessageIndex!];
              if (existingMessage is types.TextMessage) {
                final existingText =
                    existingMessage.text == _streamingPlaceholderText
                        ? ''
                        : existingMessage.text;
                currentMessages[_streamingMessageIndex!] = types.TextMessage(
                  id: existingMessage.id,
                  author: existingMessage.author,
                  createdAt: existingMessage.createdAt,
                  text: existingText + token,
                );
                state = state.copyWith(messages: currentMessages);
              }
            }
          },
          onError: (error) {
            state = state.copyWith(
              isStreaming: false,
              error: error.toString(),
            );
            _streamingMessageIndex = null;
          },
          onDone: () {
            state = state.copyWith(isStreaming: false);
            _streamingMessageIndex = null;
            onMessageSent?.call();
            _reloadMessages();
          },
        );
      } catch (e) {
        // If streaming fails unexpectedly, fall back to single-message send.
        await _fallbackToSingleMessageSend(repository, chatId, content);
      }
    } else {
      // Non-streaming mode: use MessagePair and update both messages at once.
      try {
        state = state.copyWith(isStreaming: true, error: null);
        final pair = await repository.sendMessageSync(chatId, content);

        final updatedMessages = List<types.Message>.from(state.messages)
          ..addAll([
            _messageToChatMessage(pair.userMessage),
            _messageToChatMessage(pair.botMessage),
          ]);

        onMessageSent?.call();

        state = state.copyWith(
          messages: updatedMessages,
          isStreaming: false,
          error: null,
        );
      } catch (e) {
        state = state.copyWith(
          isStreaming: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> _fallbackToSingleMessageSend(
    ChatRepository repository,
    int chatId,
    String content,
  ) async {
    try {
      final message = await repository.sendMessage(chatId, content);
      final chatMessage = _messageToChatMessage(message);
      final updatedMessages = List<types.Message>.from(state.messages);
      if (_streamingMessageIndex != null &&
          _streamingMessageIndex! < updatedMessages.length) {
        updatedMessages[_streamingMessageIndex!] = chatMessage;
      } else {
        updatedMessages.add(chatMessage);
      }

      onMessageSent?.call();

      state = state.copyWith(
        messages: updatedMessages,
        isStreaming: false,
        error: null,
      );
      _streamingMessageIndex = null;
    } catch (fallbackError) {
      state = state.copyWith(
        isStreaming: false,
        error: fallbackError.toString(),
      );
      _streamingMessageIndex = null;
    }
  }

  Future<void> _reloadMessages() async {
    if (state.chat?.id == null) return;
    try {
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(
        state.chat!.id!,
        skip: 0,
        limit: _defaultPageSize,
      );
      final chatMessages =
          messages.map((m) => _messageToChatMessage(m)).toList();

      final seenIds = <String>{};
      final uniqueMessages = <types.Message>[];
      for (final message in chatMessages) {
        if (!seenIds.contains(message.id)) {
          seenIds.add(message.id);
          uniqueMessages.add(message);
        }
      }

      uniqueMessages.sort(
        (a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0),
      );

      state = state.copyWith(messages: uniqueMessages);
    } catch (e) {
      // Silently fail reload
    }
  }

  Future<void> resetChat() async {
    if (state.chat?.id == null) {
      await initializeChat();
      if (state.chat?.id == null) {
        return;
      }
    }

    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _streamingMessageIndex = null;
    _localMessageCounter = 0;

    final chatId = state.chat!.id!;
    final repository = ref.read(chatRepositoryProvider);

    try {
      state = state.copyWith(isLoading: true, error: null, messages: []);
      await repository.resetChat(chatId);
      state = state.copyWith(
        isLoading: false,
        messages: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  types.Message _messageToChatMessage(Message message) {
    // Attach source documents in metadata so UIs can reconstruct richer
    // citation models if desired.
    final metadata = <String, Object?>{
      if (message.sourceDocuments.isNotEmpty)
        'sourceDocuments':
            message.sourceDocuments.map((s) => s.toJson()).toList(),
    };

    return types.TextMessage(
      id: message.id.toString(),
      author: message.role == MessageRole.user ? currentUser : botUser,
      createdAt: message.createdAt.millisecondsSinceEpoch,
      text: message.content,
      metadata: metadata.isEmpty ? null : metadata,
    );
  }

  void dispose() {
    _streamSubscription?.cancel();
  }

  /// Resets all cached state. Call when user logs out to prevent data leakage.
  void reset() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _streamingMessageIndex = null;
    _localMessageCounter = 0;

    state = ChatState(
      messages: [],
      isLoading: false,
      isStreaming: false,
      chat: null,
      error: null,
    );
  }
}
