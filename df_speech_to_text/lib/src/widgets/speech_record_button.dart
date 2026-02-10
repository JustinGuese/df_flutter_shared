import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../speech_to_text_notifier.dart';
import 'microphone_permission_dialog.dart';

extension _ColorOpacityCompat on Color {
  Color withOpacityCompat(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}

class SpeechRecordButton extends ConsumerStatefulWidget {
  const SpeechRecordButton({
    super.key,
    this.showPreview = true,
    this.onListeningStarted,
    this.dialogConfig,
  });

  final bool showPreview;
  final VoidCallback? onListeningStarted;
  final MicrophonePermissionDialogConfig? dialogConfig;

  @override
  ConsumerState<SpeechRecordButton> createState() => _SpeechRecordButtonState();
}

class _SpeechRecordButtonState extends ConsumerState<SpeechRecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleToggle() async {
    final speechState = ref.read(speechToTextProvider);
    final speechNotifier = ref.read(speechToTextProvider.notifier);

    // Treat both active listening and the short "finishing" window after the
    // user taps stop as a single "recording" state for the button. This makes
    // sure a second tap reliably stops recording instead of accidentally
    // starting a new session while we're finalizing the last result.
    final isRecording = speechState.isListening || _isFinishing;

    if (isRecording) {
      setState(() {
        _isFinishing = true;
      });
      // If the engine is currently listening, request a graceful stop that
      // waits for the final result. If we're already in the "finishing"
      // phase, fall back to a hard cancel so a second tap always stops
      // recording promptly.
      if (speechState.isListening) {
        await speechNotifier.stopListening();
      } else {
        await speechNotifier.cancelListening();
      }
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    } else {
      await speechNotifier.ensurePermissionAndStartListening(
        context,
        onListeningStarted: widget.onListeningStarted,
        dialogConfig: widget.dialogConfig,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(speechToTextProvider);
    final theme = Theme.of(context);

    final isListening = speechState.isListening;
    final isRecording = isListening || _isFinishing;

    if (speechState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech recognition error: ${speechState.error}'),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ref.read(speechToTextProvider.notifier).clearError();
              },
            ),
          ),
        );
      });
    }

    if (!speechState.isAvailable) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.mic_off, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Speech recognition is not available on this device.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final previewText = speechState.recognizedWords.trim();
    final showPreview =
        widget.showPreview && isRecording && previewText.isNotEmpty;
    final wordCount =
        previewText.isEmpty ? 0 : previewText.split(RegExp(r'\s+')).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _handleToggle,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isRecording
                                  ? Colors.red.shade600
                                  : theme.colorScheme.primaryContainer,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isRecording)
                              ...List.generate(3, (index) {
                                final delay = index * 0.2;
                                final animationValue =
                                    (_pulseAnimation.value + delay) % 1.0;
                                final scale = 1.0 + (animationValue * 0.5);
                                final opacity = 1.0 - animationValue;

                                return Positioned.fill(
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.red.withOpacityCompat(
                                            opacity * 0.4,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            Icon(
                              // Show a clear "stop" icon whenever recording is
                              // active so users can immediately see how to stop.
                              isRecording ? Icons.stop : Icons.mic,
                              color:
                                  isRecording
                                      ? Colors.white
                                      : theme.colorScheme.onPrimaryContainer,
                              size: 28,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isListening ? 'Listening...' : 'Tap to record',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isListening
                            ? 'Speak your thoughts. Tap again to stop.'
                            : 'Record your diary entry with your voice',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showPreview) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        previewText,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (wordCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '$wordCount words',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
