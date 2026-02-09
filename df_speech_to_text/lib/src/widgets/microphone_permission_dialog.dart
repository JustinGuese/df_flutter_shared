import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Configurable content for the microphone permission explanation dialog.
@immutable
class MicrophonePermissionDialogConfig {
  const MicrophonePermissionDialogConfig({
    this.bulletPoints = const [
      'Convert your voice into text for diary entries',
      'Enable voice input in chat conversations',
    ],
  });

  final List<String> bulletPoints;
}

extension _ColorOpacityCompat on Color {
  Color withOpacityCompat(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}

/// A dialog that explains why microphone permission is needed
/// before requesting speech-to-text functionality.
class MicrophonePermissionDialog extends StatelessWidget {
  const MicrophonePermissionDialog({
    super.key,
    this.config,
  });

  final MicrophonePermissionDialogConfig? config;

  /// Show the microphone permission explanation dialog.
  static Future<bool> show(
    BuildContext context, {
    MicrophonePermissionDialogConfig? config,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MicrophonePermissionDialog(config: config),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bullets = config?.bulletPoints ??
        const [
          'Convert your voice into text for diary entries',
          'Enable voice input in chat conversations',
        ];

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.mic_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Microphone Access'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To use speech-to-text, we need access to your microphone.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We use your microphone to:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...bullets.map((text) => _buildBulletPoint(theme, text)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.security_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your voice is processed locally on your device. '
                      'We do not store or transmit audio recordings.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            if (!kIsWeb && Platform.isIOS) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacityCompat(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be asked to allow both microphone and speech recognition access.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'You can change these permissions anytime in Settings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
