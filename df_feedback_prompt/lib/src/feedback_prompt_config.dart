import 'package:flutter/foundation.dart';

@immutable
class FeedbackPromptConfig {
  const FeedbackPromptConfig({
    required this.title,
    required this.body,
    this.emoji,
    this.primaryButtonLabel = 'Got it',
    this.secondaryButtonLabel,
    this.preferencesKey = 'feedback_prompt_shown',
    this.barrierDismissible = true,
    this.onShown,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  /// Title of the feedback dialog.
  final String title;

  /// Main body text explaining why feedback is requested.
  final String body;

  /// Optional emoji shown next to the title for a friendly touch.
  final String? emoji;

  /// Label for the primary confirmation button.
  final String primaryButtonLabel;

  /// Optional label for a secondary action (e.g. "Not now").
  final String? secondaryButtonLabel;

  /// SharedPreferences key used to persist that the prompt was already shown.
  final String preferencesKey;

  /// Whether the dialog can be dismissed by tapping outside.
  final bool barrierDismissible;

  /// Optional callback when the dialog becomes visible.
  final Future<void> Function()? onShown;

  /// Optional callback when the primary button is tapped.
  final Future<void> Function()? onPrimaryAction;

  /// Optional callback when the secondary button is tapped.
  final Future<void> Function()? onSecondaryAction;
}

