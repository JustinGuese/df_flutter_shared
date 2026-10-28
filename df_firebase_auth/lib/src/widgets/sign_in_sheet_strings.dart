import 'package:flutter/foundation.dart';

/// User-facing copy for the [DfSignInSheet] modal.
///
/// English defaults are provided. All placeholders use `{placeholder}` syntax
/// and are substituted via [fill] or dedicated helpers.
@immutable
class DfSignInSheetStrings {
  const DfSignInSheetStrings({
    this.title = 'Save your progress across devices',
    this.subtitle =
        'Sign in securely with Google or Apple to keep your data in sync.',
    this.googleButton = 'Continue with Google',
    this.appleButton = 'Continue with Apple',
    this.notNowButton = 'Not now',
    this.googleFailedMessage = 'Google Sign-In failed: {error}',
    this.appleFailedMessage = 'Apple Sign-In failed: {error}',
  });

  /// Main headline at the top of the sheet.
  final String title;

  /// Explanatory text below the headline.
  final String subtitle;

  /// Label for the Google sign-in button.
  final String googleButton;

  /// Label for the Apple sign-in button.
  final String appleButton;

  /// Label for the dismissive / skip action.
  final String notNowButton;

  /// Message template displayed in a SnackBar when Google Sign-In fails.
  final String googleFailedMessage;

  /// Message template displayed in a SnackBar when Apple Sign-In fails.
  final String appleFailedMessage;

  /// Replaces `{placeholder}` tokens in [template] with entries in [values].
  static String fill(String template, Map<String, Object?> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return result;
  }

  /// Convenience formatter for [googleFailedMessage].
  String fillGoogleFailed(Object error) =>
      fill(googleFailedMessage, <String, Object?>{'error': error});

  /// Convenience formatter for [appleFailedMessage].
  String fillAppleFailed(Object error) =>
      fill(appleFailedMessage, <String, Object?>{'error': error});

  /// Returns a copy of this strings instance with the given fields replaced.
  DfSignInSheetStrings copyWith({
    String? title,
    String? subtitle,
    String? googleButton,
    String? appleButton,
    String? notNowButton,
    String? googleFailedMessage,
    String? appleFailedMessage,
  }) => DfSignInSheetStrings(
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    googleButton: googleButton ?? this.googleButton,
    appleButton: appleButton ?? this.appleButton,
    notNowButton: notNowButton ?? this.notNowButton,
    googleFailedMessage: googleFailedMessage ?? this.googleFailedMessage,
    appleFailedMessage: appleFailedMessage ?? this.appleFailedMessage,
  );
}
