import 'package:flutter/foundation.dart';

/// User-facing copy for the notification priming sheet.
///
/// Defaults are English: a shared package must not impose a language on the
/// apps that consume it. Pass a localized instance to override — see
/// `ensureDfNotificationPermission`.
@immutable
class DfNotificationStrings {
  const DfNotificationStrings({
    this.primingTitle = 'Stay on track',
    this.primingBody =
        'Turn on reminders so you never miss what matters. '
        'You can change this anytime in settings.',
    this.primingAcceptLabel = 'Yes, remind me',
    this.primingDeclineLabel = 'Not now',
  });

  /// Heading of the soft-ask sheet, shown before the OS permission prompt.
  final String primingTitle;

  /// Body copy explaining the value of turning reminders on.
  final String primingBody;

  /// Button that proceeds to the real OS permission dialog.
  final String primingAcceptLabel;

  /// Button that dismisses the sheet without touching the OS prompt, so it
  /// can be offered again later.
  final String primingDeclineLabel;
}
