import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ai_consent_config.dart';
import 'ai_data_consent_service.dart';

/// Modal consent dialog disclosing AI data processing to the user.
///
/// Use [AiDataConsentDialog.showIfNeeded] as the entry point – it checks
/// whether consent has already been given and only shows the dialog when needed.
class AiDataConsentDialog extends StatelessWidget {
  const AiDataConsentDialog({super.key, required this.config});

  final AiConsentConfig config;

  /// Shows the consent dialog if consent has not yet been granted.
  ///
  /// Returns `true` if the user consents (or already had consented).
  /// Returns `false` if the user declines or the context is no longer mounted.
  static Future<bool> showIfNeeded(
    BuildContext context, {
    required AiDataConsentService service,
    required AiConsentConfig config,
  }) async {
    if (await service.hasConsented()) return true;
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AiDataConsentDialog(config: config),
    );

    if (result == true) {
      await service.grantConsent();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Expanded(child: Text('AI Data Processing')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(config.introText, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ...config.dataItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DataItem(
                  icon: item.icon,
                  title: item.title,
                  description: item.description,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      config.processorText,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall,
                children: [
                  const TextSpan(text: 'For full details, see our '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse(config.privacyPolicyUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('I Agree'),
        ),
      ],
    );
  }
}

class _DataItem extends StatelessWidget {
  const _DataItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(description, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
