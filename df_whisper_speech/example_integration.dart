// Example: Integrating df_whisper_speech into a Flutter app
//
// This shows how psychdiary uses df_whisper_speech for voice-to-text in chat and diary entry forms.

import 'package:df_whisper_speech/df_whisper_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// STEP 1: Override whisperDioProvider in main.dart ProviderScope
// ============================================================================

// import 'package:df_firebase_auth/df_firebase_auth.dart';  // provides apiClientProvider
//
// void main() {
//   runApp(
//     ProviderScope(
//       overrides: [
//         // ... other overrides ...
//         whisperDioProvider.overrideWith(
//           (ref) => ref.watch(apiClientProvider),  // Inject authenticated Dio
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// ============================================================================
// STEP 2: Use in a chat/diary screen with text input
// ============================================================================

class ChatScreenExample extends ConsumerStatefulWidget {
  const ChatScreenExample({super.key});

  @override
  ConsumerState<ChatScreenExample> createState() => _ChatScreenExampleState();
}

class _ChatScreenExampleState extends ConsumerState<ChatScreenExample> {
  late final TextEditingController _textController;
  late final SpeechTextController _speechTextController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    // Helper for cursor-aware streaming text insertion
    _speechTextController = SpeechTextController(_textController);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(whisperSpeechProvider);

    // Show error snackbars
    ref.listen(whisperSpeechProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    // Auto-insert transcribed text into controller
    if (speechState.transcribedText.isNotEmpty &&
        speechState.status == WhisperSpeechStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _speechTextController.updateWithSpeech(speechState.transcribedText);
      });
    }

    return Column(
      children: [
        // Text input with mic button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type or tap mic to speak...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onTap: () {
                    // Capture text state when user starts typing (for speech context)
                    _speechTextController.captureBaseState();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Mic button: auto-updates on tap, shows status
              const WhisperRecordButton(),
            ],
          ),
        ),

        // Debug: show speech state
        if (speechState.status == WhisperSpeechStatus.recording)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Recording: ${speechState.recordingDuration.inSeconds}s',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        if (speechState.status == WhisperSpeechStatus.transcribing)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

// ============================================================================
// STEP 3: Manual control (if you need programmatic recording)
// ============================================================================

class ManualRecordingExample extends ConsumerWidget {
  const ManualRecordingExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(whisperSpeechProvider);
    final notifier = ref.read(whisperSpeechProvider.notifier);

    return Column(
      children: [
        ElevatedButton(
          onPressed: speechState.status == WhisperSpeechStatus.idle
              ? () => notifier.startRecording()
              : null,
          child: const Text('Start Recording'),
        ),
        ElevatedButton(
          onPressed: speechState.status == WhisperSpeechStatus.recording
              ? () => notifier.stopAndTranscribe()
              : null,
          child: const Text('Stop & Transcribe'),
        ),
        ElevatedButton(
          onPressed: speechState.status != WhisperSpeechStatus.idle
              ? () => notifier.cancel()
              : null,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ============================================================================
// STEP 4: Custom config (optional)
// ============================================================================

// If you need different timeouts or endpoint:
//
// ProviderScope(
//   overrides: [
//     whisperSpeechConfigProvider.overrideWithValue(
//       const WhisperSpeechConfig(
//         transcribeEndpoint: '/api/v2/transcribe',  // Custom endpoint
//         transcriptionTimeout: Duration(seconds: 90),  // Longer timeout
//         errorBlockDuration: Duration(minutes: 1),  // Longer block after error
//       ),
//     ),
//   ],
//   child: const MyApp(),
// )
