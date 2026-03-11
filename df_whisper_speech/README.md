# df_whisper_speech

Speech-to-text integration for Flutter apps using the Whisper backend API with SSE streaming, Riverpod state management, and platform-specific audio I/O.

## Features

- 🎤 **Audio Recording** — Platform-specific recording (mobile/web)
- 🌊 **SSE Streaming** — Real-time transcription via Server-Sent Events
- 🔌 **Riverpod Integration** — `whisperSpeechProvider` for easy state management
- 🚫 **Service Error Handling** — Friendly error messages + auto-disable button on service unavailability
- 📱 **Platform Support** — iOS, Android, Web
- ⚙️ **Configurable** — Custom timeouts, endpoints, block durations via `WhisperSpeechConfig`

## Installation

Add to `pubspec.yaml`:

```yaml
df_whisper_speech:
  path: ../../../df_flutter_shared/df_whisper_speech  # or git path
```

## Basic Usage

### 1. Override `whisperDioProvider` in `ProviderScope`

Inject your authenticated Dio client:

```dart
import 'package:df_whisper_speech/df_whisper_speech.dart';

ProviderScope(
  overrides: [
    whisperDioProvider.overrideWith(
      (ref) => ref.watch(apiClientProvider),  // Your authenticated Dio
    ),
  ],
  child: MyApp(),
)
```

### 2. Use `WhisperRecordButton` Widget

Drop it into a text input area:

```dart
import 'package:df_whisper_speech/df_whisper_speech.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(whisperSpeechProvider);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: const InputDecoration(hintText: 'Say something...'),
          ),
        ),
        const WhisperRecordButton(),  // Mic button that updates provider
      ],
    );
  }
}
```

### 3. Listen to Transcription Updates

```dart
final speechState = ref.watch(whisperSpeechProvider);

if (speechState.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(speechState.error!)),
  );
}

if (speechState.transcribedText.isNotEmpty) {
  _textController.text = speechState.transcribedText;
}
```

### 4. Manual Control (Optional)

```dart
final notifier = ref.read(whisperSpeechProvider.notifier);

// Start recording
await notifier.startRecording();

// Stop and transcribe
await notifier.stopAndTranscribe();

// Cancel
await notifier.cancel();

// Reset state
notifier.reset();
```

## Configuration

Override `whisperSpeechConfigProvider` for custom timeouts:

```dart
whisperSpeechConfigProvider.overrideWithValue(
  const WhisperSpeechConfig(
    transcribeEndpoint: '/speech/transcribe/stream',
    transcriptionTimeout: Duration(seconds: 120),  // Longer timeout
    transcriptionReceiveTimeout: Duration(seconds: 60),
    errorBlockDuration: Duration(seconds: 45),  // Longer block after error
  ),
),
```

## State Management

### `WhisperSpeechState`

```dart
class WhisperSpeechState {
  final WhisperSpeechStatus status;      // idle, recording, transcribing
  final String transcribedText;          // Streamed text from backend
  final String? error;                   // Error message if any
  final Duration recordingDuration;      // Elapsed time while recording
  final bool isBlocked;                  // True if button disabled after service error
}
```

### Error Handling

- **Service errors** (timeouts, connection issues) → Friendly message + 30s button disable
- **Permission errors** → "Microphone permission denied" message
- **Recording errors** → "Failed to start recording" message
- **Transcription errors** → Detailed error or "Transcription failed"

## Platform Details

### Mobile (iOS/Android)

- Uses `record` package to save audio as `.m4a` to temp directory
- Sends multipart form data to backend
- Cleans up temp files after transcription

### Web

- Uses Web Audio API to record Blob
- Converts Blob to Uint8List via fetch
- Sends multipart form data to backend

## Backend API

This package expects a backend endpoint at (configurable):

```
POST /speech/transcribe/stream
Content-Type: multipart/form-data

Field: audio (file, audio/mp4 on mobile, audio/webm on web)

Response: Server-Sent Events (text/event-stream)
Format:
  event: token
  data: <recognized_text_chunk>

  event: end
  data: (optional metadata)
```

## Architecture

- **Notifier** — `WhisperSpeechNotifier` manages recording, transcription, errors, and blocking
- **Config** — `WhisperSpeechConfig` centralizes timeouts + endpoint
- **Recording I/O** — Conditional exports for platform-specific file/blob handling
- **Widget** — `WhisperRecordButton` UI component with status-aware styling
- **Text Helper** — `SpeechTextController` for cursor-aware text insertion during streaming

## Testing

The package includes conditional compilation for stub implementations on unsupported platforms. Tests can mock `whisperDioProvider`:

```dart
test('transcription succeeds', () async {
  final container = ProviderContainer(
    overrides: [
      whisperDioProvider.overrideWithValue(mockDio),
    ],
  );

  final notifier = container.read(whisperSpeechProvider.notifier);
  await notifier.startRecording();
  // ...
});
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "whisperDioProvider must be overridden" | Override in ProviderScope with authenticated Dio |
| Button stays disabled after error | Wait for `errorBlockDuration` (default 30s), or clear manually |
| No audio file to transcribe | Ensure `getRecordingPath()` succeeded; check disk space |
| Transcription timeout | Increase `transcriptionTimeout` in config |
| "Speech unavailable" message | Backend service unreachable; check connection |

## Contributing

This package is part of the [df_flutter_shared](https://github.com/JustinGuese/df_flutter_shared) monorepo. Updates that diverge between apps should be centralized here to avoid duplication.

## License

See parent repository.
