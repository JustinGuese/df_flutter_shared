import 'package:flutter/material.dart';

/// Configurable content for the privacy tracking consent dialog.
@immutable
class PrivacyTrackingDialogConfig {
  const PrivacyTrackingDialogConfig({
    this.bulletPoints = const [
      'Understand how you use the app',
      'Fix bugs and improve performance',
      'Measure which ads bring users to our app',
    ],
    this.infoText =
        'We share anonymous usage data with Meta (Facebook) for ad attribution and analytics. '
        'This helps us measure ad effectiveness. Your personal diary entries are never shared.',
  });

  final List<String> bulletPoints;
  final String infoText;
}

/// A dialog that explains why tracking permission is requested.
class PrivacyTrackingDialog extends StatelessWidget {
  const PrivacyTrackingDialog({
    super.key,
    this.config,
  });

  final PrivacyTrackingDialogConfig? config;

  /// Show the privacy tracking dialog.
  static Future<bool> show(
    BuildContext context, {
    PrivacyTrackingDialogConfig? config,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrivacyTrackingDialog(config: config),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = config ?? const PrivacyTrackingDialogConfig();

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Privacy & Analytics'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We use analytics and ad attribution to improve your app experience.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We collect usage data to:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...cfg.bulletPoints.map((text) => _buildBulletPoint(theme, text)),
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
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cfg.infoText,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can change this permission anytime in Settings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not Now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
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
