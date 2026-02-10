import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feedback_prompt_providers.dart';

extension _ColorOpacityCompat on Color {
  Color withOpacityCompat(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}

/// Listens for the first time the user reaches the wrapped subtree and shows
/// a friendly feedback dialog once, then remembers that it was shown.
class FeedbackPromptListener extends ConsumerStatefulWidget {
  const FeedbackPromptListener({
    super.key,
    required this.child,
  });

  /// The subtree where the prompt should be evaluated.
  ///
  /// Typically this wraps the main logged-in home screen of the app.
  final Widget child;

  @override
  ConsumerState<FeedbackPromptListener> createState() =>
      _FeedbackPromptListenerState();
}

class _FeedbackPromptListenerState
    extends ConsumerState<FeedbackPromptListener> {
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowDialog();
    });
  }

  Future<void> _maybeShowDialog() async {
    if (!mounted || _hasChecked) return;
    _hasChecked = true;

    final config = ref.read(feedbackPromptConfigProvider);
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(config.preferencesKey) ?? false;
    if (alreadyShown) return;

    // Mark as shown as soon as we decide to show, to avoid duplicate dialogs
    // if the widget rebuilds quickly.
    await prefs.setBool(config.preferencesKey, true);

    if (config.onShown != null) {
      await config.onShown!();
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: config.barrierDismissible,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.emoji_emotions_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  config.emoji != null
                      ? '${config.emoji!}  ${config.title}'
                      : config.title,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withOpacityCompat(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacityCompat(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can always share feedback later from the Profile tab as well.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (config.secondaryButtonLabel != null)
              TextButton(
                onPressed: () async {
                  if (config.onSecondaryAction != null) {
                    await config.onSecondaryAction!();
                  }
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(config.secondaryButtonLabel!),
              ),
            FilledButton(
              onPressed: () async {
                if (config.onPrimaryAction != null) {
                  await config.onPrimaryAction!();
                }
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(config.primaryButtonLabel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

