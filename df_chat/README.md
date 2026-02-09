# df_chat

Reusable AI chat backend: Dio-based repository with configurable endpoints and SSE streaming, Riverpod state (`ChatController` / `ChatState`), and `flutter_chat_types`-compatible models. Used by [DataFortress.cloud](https://datafortress.cloud/) apps (e.g. PsychDiary). The **UI** (chat screen, quick actions, entry links) stays in the app; this package provides only the data layer.

---

## What’s included

- **ChatConfig** – Endpoint paths (with `{chatId}` placeholder), default page size, streaming placeholder text, user/bot display names.
- **ChatRepository** – `getChat()`, `getMessages()`, `sendMessage()`, `resetChat()`, `streamMessage()` (SSE token stream). Paths and page size come from config.
- **ChatState / ChatController** – Riverpod `Notifier`: load chat, send message (streaming or fallback), reset, and optional `onMessageSent` callback for analytics.
- **Models** – `Chat`, `Message`, `MessageRole`, `SourceDocument` (JSON-serializable; `SourceDocument` is optional for apps that don’t use it).

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

3. Optionally override `chatConfigProvider` if you need different endpoints or display names (defaults: `/chats`, `/chats/{chatId}/messages`, etc.).

4. In your chat screen, wire analytics (or other side effects) when a message is sent:

   ```dart
   ref.read(chatProvider.notifier).onMessageSent = () {
     AnalyticsService.instance.logChatMessageSent();
   };
   ```

5. On logout (or account switch), invalidate chat state so the next user doesn’t see the previous user’s messages: `ref.invalidate(chatProvider)` or call `ref.read(chatProvider.notifier).reset()`.

---

## Dependencies

- `flutter`, `flutter_riverpod`, `flutter_chat_types`, `dio`, `json_annotation`. No `flutter_chat_ui` or `df_analytics`; the app provides the UI and analytics callback.
