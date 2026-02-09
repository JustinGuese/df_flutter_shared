/// Configuration for chat API endpoints and display.
class ChatConfig {
  const ChatConfig({
    this.chatEndpoint = '/chats',
    this.messagesEndpoint = '/chats/{chatId}/messages',
    this.streamEndpoint = '/chats/{chatId}/stream',
    this.resetEndpoint = '/chats/{chatId}/reset',
    this.defaultPageSize = 20,
    this.streamingPlaceholderText = 'AI is thinking…',
    this.currentUserName = 'You',
    this.botUserName = 'AI Assistant',
  });

  final String chatEndpoint;
  final String messagesEndpoint;
  final String streamEndpoint;
  final String resetEndpoint;
  final int defaultPageSize;
  final String streamingPlaceholderText;
  final String currentUserName;
  final String botUserName;
}
