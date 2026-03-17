# df_audio_capture

A generic cross-platform audio recording library for Flutter.

## Features

- **Microphone recording** on all platforms (Android, iOS, macOS, Windows, Linux, Web).
- **System / Loopback recording** on Desktop platforms (Windows, Linux, macOS) using `desktop_audio_capture`.
- **Automatic platform routing**: Handles `AudioCaptureService` routing to the correct backend based on the current platform.
- **Audio levels**: Stream of decibel levels for real-time visualization.
- **WAV/M4A support**: Configurable output formats based on platform capabilities.

## Usage

```dart
import 'package:df_audio_capture/df_audio_capture.dart';

// Initialize the service with a directory for recordings
final audioService = AudioCaptureService(recordingsDir: myDirectory);

// Start recording
await audioService.startRecording();

// Listen to audio levels
audioService.audioLevelStream?.listen((level) {
  print('Decibels: $level');
});

// Stop and get files (one for mic, optional one for system audio)
final files = await audioService.stopAndSave();
print('Saved ${files.length} files');
```
