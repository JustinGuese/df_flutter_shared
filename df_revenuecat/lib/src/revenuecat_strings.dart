import 'package:flutter/foundation.dart';

/// User-facing copy for RevenueCat and paywall UI components.
///
/// Defaults are English. All placeholder interpolation is done via [fill]
/// or dedicated helper methods.
@immutable
class DfRevenueCatStrings {
  const DfRevenueCatStrings({
    this.upgradeLabel = 'Upgrade to Pro',
    this.trialStartTemplate = 'Start {days}-day free trial',
    this.trialTryTemplate = 'Try Pro free for {days} days',
    this.webDialogTitle = 'Premium Subscription',
    this.webDialogDescription =
        'Premium subscriptions are managed through the mobile app stores.',
    this.webDialogInstruction =
        'Download the mobile app on your phone to subscribe and sign in. '
        'Your subscription will automatically sync across your devices.',
    this.webDialogButtonLabel = 'Got it',
  });

  /// Default label for upgrade buttons when no trial is available.
  final String upgradeLabel;

  /// Template for trial CTA button (e.g. "Start 7-day free trial").
  final String trialStartTemplate;

  /// Template for trial pitch (e.g. "Try Pro free for 7 days").
  final String trialTryTemplate;

  /// Title for web subscription info dialog.
  final String webDialogTitle;

  /// Description paragraph for web subscription info dialog.
  final String webDialogDescription;

  /// Instruction paragraph for web subscription info dialog.
  final String webDialogInstruction;

  /// Dismiss button label for web subscription info dialog.
  final String webDialogButtonLabel;

  /// Replaces `{placeholder}` tokens in [template] with entries in [values].
  static String fill(String template, Map<String, Object?> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return result;
  }

  /// Formatted CTA label for a free trial of [days] length.
  String fillTrialStart(int days) => fill(trialStartTemplate, {'days': days});

  /// Formatted pitch label for a free trial of [days] length.
  String fillTrialTry(int days) => fill(trialTryTemplate, {'days': days});
}
