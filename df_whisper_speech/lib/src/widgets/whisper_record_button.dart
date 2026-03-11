import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../whisper_speech_provider.dart';

/// Compact microphone button wired to [whisperSpeechProvider].
///
/// - Idle: mic icon
/// - Recording: red pulsing mic with elapsed time
/// - Transcribing: spinner
class WhisperRecordButton extends ConsumerWidget {
  const WhisperRecordButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(whisperSpeechProvider);
    final notifier = ref.read(whisperSpeechProvider.notifier);
    final theme = Theme.of(context);

    Widget child = const SizedBox.shrink();
    VoidCallback? onTap;

    switch (state.status) {
      case WhisperSpeechStatus.idle:
        if (state.isBlocked) {
          child = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_off, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Speech unavailable',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          onTap = null;
          break;
        }
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_none, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Tap to speak',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        );
        onTap = () => notifier.startRecording();
        break;
      case WhisperSpeechStatus.recording:
        final seconds = state.recordingDuration.inSeconds;
        final minutesStr = (seconds ~/ 60).toString();
        final secondsStr = (seconds % 60).toString().padLeft(2, '0');
        final timeLabel = '$minutesStr:$secondsStr';
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              timeLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        );
        onTap = () => notifier.stopAndTranscribe();
        break;
      case WhisperSpeechStatus.transcribing:
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Transcribing…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        );
        onTap = null; // Disabled while transcribing
        break;
    }

    final backgroundColor = state.status == WhisperSpeechStatus.recording
        ? Colors.red
        : state.isBlocked
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.primaryContainer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: child,
        ),
      ),
    );
  }
}
