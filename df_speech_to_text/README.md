# df_speech_to_text

Reusable Flutter package for speech-to-text: Riverpod notifier, permission handling, and a record button widget. Supports configurable listen/pause duration, optional analytics callback, and a customizable microphone permission dialog. Used in apps by [DataFortress.cloud](https://datafortress.cloud/).

---

## Features

- **SpeechToTextNotifier** – Riverpod `Notifier` that manages availability, listening state, recognized text, and errors.
- **SpeechTextController** – Inserts recognized text into a `TextEditingController` at the cursor position (with base-state capture for live preview).
- **SpeechRecordButton** – UI widget that toggles listening and shows live preview; supports an optional analytics callback when listening starts.
- **MicrophonePermissionDialog** – Explains why microphone access is needed; bullet points and copy are configurable.
- **Config** – `SpeechToTextConfig` (and `speechToTextConfigProvider`) for listen duration, pause duration, max restarts, and finalize timeout.

---

## Installation

Add a path dependency in your app’s `pubspec.yaml`:

```yaml
dependencies:
  df_speech_to_text:
    path: ../packages/df_speech_to_text  # adjust path to your repo layout
```

Then run `flutter pub get`.

**Dependencies:** `flutter`, `flutter_riverpod`, `speech_to_text`, `permission_handler`. Your app must include these (or compatible versions) when using the package.

---

## Configuration (optional)

Override the default config in your app’s `ProviderScope` if you need different timing or limits:

```dart
import 'package:df_speech_to_text/df_speech_to_text.dart';

ProviderScope(
  overrides: [
    speechToTextConfigProvider.overrideWithValue(
      const SpeechToTextConfig(
        listenDuration: Duration(seconds: 60),
        pauseDuration: Duration(seconds: 3),
        maxRestarts: 20,
        finalizeTimeout: Duration(milliseconds: 600),
      ),
    ),
  ],
  child: MyApp(),
)
```

---

## Usage

### 1. Use the record button (with analytics)

```dart
import 'package:df_speech_to_text/df_speech_to_text.dart';

// In your widget (e.g. entry form or chat):
SpeechRecordButton(
  showPreview: true,
  onListeningStarted: () {
    // Optional: log analytics when user starts speaking
    AnalyticsService.instance.logSpeechToTextUsed();
  },
  dialogConfig: MicrophonePermissionDialogConfig(
    bulletPoints: [
      'Convert your voice into text for diary entries',
      'Enable voice input in chat',
    ],
  ),
)
```

### 2. Programmatic control (permission + start listening)

```dart
final notifier = ref.read(speechToTextProvider.notifier);

final started = await notifier.ensurePermissionAndStartListening(
  context,
  onResult: (finalText) {
    // Insert or use finalText when user stops
  },
  onListeningStarted: () => MyAnalytics.logSpeechUsed(),
  dialogConfig: myDialogConfig,  // optional
);

if (started) {
  // Listening is active; use ref.watch(speechToTextProvider) for state
}
```

### 3. Insert recognized text into a text field

```dart
final textController = TextEditingController();
final speechController = SpeechTextController(textController);

// When starting speech (e.g. in onResult or when you start listening):
speechController.captureBaseState();

// When you get final text (e.g. from onResult or from state after stop):
speechController.updateWithSpeech(recognizedText);

// When user edits manually again or you want to reset:
speechController.reset();
```

### 4. Watch state (listening, recognized words, errors)

```dart
final state = ref.watch(speechToTextProvider);

if (state.error != null) { ... }
if (state.isListening) { ... }
final text = state.recognizedWords;
```

---

## API overview

| Export | Description |
|--------|-------------|
| `speechToTextProvider` | `NotifierProvider<SpeechToTextNotifier, SpeechToTextState>` |
| `speechToTextConfigProvider` | `Provider<SpeechToTextConfig>` (override in app if needed) |
| `SpeechToTextNotifier` | Methods: `startListening`, `stopListening`, `ensurePermissionAndStartListening`, `clearError`, `clearRecognizedWords`, permission helpers |
| `SpeechToTextState` | `isAvailable`, `isListening`, `recognizedWords`, `error`, `isInitialized` |
| `SpeechTextController` | `captureBaseState()`, `updateWithSpeech(String)`, `reset()` |
| `SpeechRecordButton` | Params: `showPreview`, `onListeningStarted`, `dialogConfig` |
| `MicrophonePermissionDialog` | `show(BuildContext, { config })`; `MicrophonePermissionDialogConfig` for bullets |
| `SpeechToTextConfig` | `listenDuration`, `pauseDuration`, `maxRestarts`, `finalizeTimeout` |

---

## Platform notes

- **iOS**: Microphone (and typically speech recognition) permission; the package uses `permission_handler` for the microphone and relies on `speech_to_text` for recognition.
- **Android**: Microphone permission via `permission_handler`.
- **Web**: Permissions are handled by the browser; the package skips native permission flows on web.
