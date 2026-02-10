/// Configuration for chat API endpoints and display.
class ChatConfig {
  const ChatConfig({
    this.basePath,
    this.chatEndpoint = '/chats',
    this.messagesEndpoint = '/chats/{chatId}/messages',
    this.streamEndpoint = '/chats/{chatId}/stream',
    this.resetEndpoint = '/chats/{chatId}/reset',
    this.defaultPageSize = 20,
    this.streamingPlaceholderText = 'AI is thinking…',
    this.currentUserName = 'You',
    this.botUserName = 'AI Assistant',
  });

  /// Optional base path that all endpoints are resolved relative to.
  ///
  /// Example (DocumentChat-style API):
  ///   basePath: '/api/v1/projects/my-project',
  ///   chatEndpoint: '/chats/my-chat',
  ///   messagesEndpoint: '/chats/my-chat/messages',
  ///   streamEndpoint: '/chats/my-chat/stream',
  ///   resetEndpoint: '/chats/my-chat/reset'
  ///
  /// When [basePath] is null, endpoints are used as-is.
  final String? basePath;

  /// Endpoint used by [ChatRepository.getChat].
  final String chatEndpoint;

  /// Endpoint template used by [ChatRepository.getMessages] and
  /// [ChatRepository.sendMessage]/[ChatRepository.sendMessageSync].
  ///
  /// The `{chatId}` placeholder, when present, will be replaced with the
  /// numeric chat id.
  final String messagesEndpoint;

  /// Optional streaming endpoint template for SSE-style token streaming.
  ///
  /// If this is null or an empty string, [ChatController.sendMessage] will use
  /// the non-streaming [ChatRepository.sendMessageSync] path instead.
  final String? streamEndpoint;

  /// Endpoint template used by [ChatRepository.resetChat].
  final String resetEndpoint;

  /// Default page size for message history.
  final int defaultPageSize;

  /// Placeholder text shown while the assistant is streaming a response.
  final String streamingPlaceholderText;

  /// Display name for the current user in the chat UI.
  final String currentUserName;

  /// Display name for the assistant/bot in the chat UI.
  final String botUserName;
}
