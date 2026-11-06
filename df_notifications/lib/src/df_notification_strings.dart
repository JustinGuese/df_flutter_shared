import 'package:flutter/foundation.dart';

/// User-facing copy for the notification priming sheet and settings toggle tile.
///
/// Defaults are English: a shared package must not impose a language on the
/// apps that consume it. Pass a localized instance to override — see
/// `ensureDfNotificationPermission` and `DfNotificationToggleTile`.
@immutable
class DfNotificationStrings {
  const DfNotificationStrings({
    this.primingTitle = 'Stay on track',
    this.primingBody =
        'Turn on reminders so you never miss what matters. '
        'You can change this anytime in settings.',
    this.primingAcceptLabel = 'Yes, remind me',
    this.primingDeclineLabel = 'Not now',
    this.tileTitle = 'Notifications',
    this.tileSubtitle,
    this.enabledMessage = 'Notifications enabled.',
    this.permissionDeniedMessage = 'Notification permission was not granted.',
    this.disabledMessage = 'Notifications disabled.',
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

  /// Default title for [DfNotificationToggleTile].
  final String tileTitle;

  /// Default subtitle for [DfNotificationToggleTile].
  final String? tileSubtitle;

  /// SnackBar message shown when notifications are successfully enabled.
  final String enabledMessage;

  /// SnackBar message shown when notification permission was denied.
  final String permissionDeniedMessage;

  /// SnackBar message shown when notifications are disabled.
  final String disabledMessage;

  /// Returns a copy of these strings with the given fields replaced.
  DfNotificationStrings copyWith({
    String? primingTitle,
    String? primingBody,
    String? primingAcceptLabel,
    String? primingDeclineLabel,
    String? tileTitle,
    String? tileSubtitle,
    String? enabledMessage,
    String? permissionDeniedMessage,
    String? disabledMessage,
  }) {
    return DfNotificationStrings(
      primingTitle: primingTitle ?? this.primingTitle,
      primingBody: primingBody ?? this.primingBody,
      primingAcceptLabel: primingAcceptLabel ?? this.primingAcceptLabel,
      primingDeclineLabel: primingDeclineLabel ?? this.primingDeclineLabel,
      tileTitle: tileTitle ?? this.tileTitle,
      tileSubtitle: tileSubtitle ?? this.tileSubtitle,
      enabledMessage: enabledMessage ?? this.enabledMessage,
      permissionDeniedMessage:
          permissionDeniedMessage ?? this.permissionDeniedMessage,
      disabledMessage: disabledMessage ?? this.disabledMessage,
    );
  }
}
