# df_chat

Reusable AI chat backend: Dio-based repository with configurable endpoints and SSE streaming, Riverpod state (`ChatController` / `ChatState`), and `flutter_chat_types`-compatible models. Used by [DataFortress.cloud](https://datafortress.cloud/) apps (e.g. PsychDiary). The **UI** (chat screen, quick actions, entry links) stays in the app; this package provides only the data layer.

---

## What’s included

- **ChatConfig**
  - Endpoint paths (with `{chatId}` placeholder) and **optional `basePath`** (e.g. `/api/v1/projects/{projectName}`) so all endpoints can be resolved relative to a project or scope.
  - Default page size, streaming placeholder text, user/bot display names.
  - Optional `streamEndpoint`; when null/empty, the controller uses non-streaming mode.
- **ChatRepository**
  - `getChat()`, `getMessages()`, `sendMessage()`, `resetChat()`, `streamMessage()` (SSE token stream).
  - **Non-streaming `sendMessageSync(...)`** that returns a `MessagePair` (user + bot messages) for backends that respond with a full pair instead of a stream.
  - All paths are resolved via `basePath` + endpoint templates.
- **ChatState / ChatController**
  - Riverpod `Notifier`: load chat, send message (streaming or non-streaming), reset, and optional `onMessageSent` callback for analytics.
  - In **streaming mode** (when `streamEndpoint` is set), `sendMessage` behaves as before using SSE tokens.
  - In **non-streaming mode** (when `streamEndpoint` is null/empty), `sendMessage` calls `sendMessageSync` and updates state from the returned `MessagePair`.
- **Models**
  - `Chat`, `Message`, `MessageRole`.
  - **`SourceDocument`** with richer citation fields for document-centric chats:
    - `entryId`, `entryDate`, `snippet`.
    - Optional: `documentId`, `fileName`, `previewUrl`, `downloadUrl`, `chunkText`, `startIndex`, `endIndex`.
  - `MessagePair` – wraps a user `Message` and bot `Message` for non-streaming responses.

---

## Setup

1. Add a path dependency in your app’s `pubspec.yaml`:

   ```yaml
   dependencies:
     df_chat:
       path: ../packages/df_chat
   ```

2. You must **override** `chatRepositoryProvider` so the package gets a real `ChatRepository`. In your app’s `main.dart` (inside `ProviderScope`):

   ```dart
   import 'package:df_chat/df_chat.dart';
   import 'package:df_firebase_auth/df_firebase_auth.dart'; // for apiClientProvider

   // In runApp(ProviderScope(overrides: [
     chatRepositoryProvider.overrideWith(
       (ref) => ChatRepository(ref.watch(apiClientProvider)),
     ),
   // ], ...))
   ```

3. Optionally override `chatConfigProvider` if you need different endpoints or display names (defaults: `/chats`, `/chats/{chatId}/messages`, etc.), or to enable:

   - **Project-scoped chats** via `basePath`:
     ```dart
     final chatConfigOverride = chatConfigProvider.overrideWith(
       (ref) => const ChatConfig(
         basePath: '/api/v1/projects/my-project',
         chatEndpoint: '/chats/my-chat',
         messagesEndpoint: '/chats/my-chat/messages',
         // streamEndpoint: '/chats/my-chat/stream', // optional
       ),
     );
     ```

   - **Non-streaming backends** by leaving `streamEndpoint` null/empty and using `sendMessageSync`:
     ```dart
     const ChatConfig(
       basePath: '/api/v1/projects/my-project',
       chatEndpoint: '/chats/my-chat',
       messagesEndpoint: '/chats/my-chat/messages',
       streamEndpoint: '', // or null -> use MessagePair-based non-streaming
     );
     ```

4. In your chat screen, wire analytics (or other side effects) when a message is sent:

   ```dart
   ref.read(chatProvider.notifier).onMessageSent = () {
     AnalyticsService.instance.logChatMessageSent();
   };
   ```

5. On logout (or account switch), invalidate chat state so the next user doesn’t see the previous user’s messages: `ref.invalidate(chatProvider)` or call `ref.read(chatProvider.notifier).reset()`.

---

## Accessing citations from ChatController

When your backend returns `source_documents` in message JSON, `df_chat` maps them to `SourceDocument` and then attaches them to `flutter_chat_types.TextMessage` metadata in `ChatController`:

- Each `types.TextMessage` in `ChatState.messages` may contain:
  ```dart
  final meta = (message as types.TextMessage).metadata;
  final docsJson = meta?['sourceDocuments'] as List<dynamic>?;
  ```
- `docsJson` is a `List<Map<String, dynamic>>` compatible with `SourceDocument.fromJson`, so apps can reconstruct richer domain models (e.g. app-specific `Citation`) for UI components like citation cards, previews, download links, etc.

---

## Dependencies

- `flutter`, `flutter_riverpod`, `flutter_chat_types`, `dio`, `json_annotation`. No `flutter_chat_ui` or `df_analytics`; the app provides the UI and analytics callback.
