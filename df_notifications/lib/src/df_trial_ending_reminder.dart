import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'df_notification_ids.dart';
import 'df_reminder.dart';
import 'df_reminder_service.dart';

/// User-facing copy for the trial-ending reminder.
@immutable
class DfTrialEndingReminderStrings {
  const DfTrialEndingReminderStrings({
    this.title = 'Your free trial ends soon',
    this.body =
        'Your subscription renews unless you cancel in your store settings.',
  });

  final String title;
  final String body;
}

/// Schedules a heads-up reminder before a free trial converts.
///
/// Only scheduled when the user has already allowed notifications (via the
/// boolean preference under [prefsKey]), and skips silently if the calculated
/// fire time is less than 1 hour away from current time.
abstract final class DfTrialEndingReminder {
  /// Default notification id for the trial-ending reminder.
  static final int defaultId = DfNotificationIds.slot(1);

  /// Default lead time before trial expiration (2 days).
  static const Duration defaultLeadTime = Duration(days: 2);

  /// Schedules a one-shot trial ending reminder.
  ///
  /// Returns the scheduled [DfReminder], or `null` if the reminder was skipped
  /// because notifications are disabled in [prefsKey] or the fire time is
  /// less than 1 hour away.
  static Future<DfReminder?> schedule(
    DateTime trialEnd, {
    Duration leadTime = defaultLeadTime,
    String prefsKey = 'notifications_enabled',
    int? id,
    String? title,
    String? body,
    String payload = 'trial_ending',
    DfNotificationChannel channel = DfNotificationChannel.defaultChannel,
    DfTrialEndingReminderStrings strings = const DfTrialEndingReminderStrings(),
    DfReminderService? service,
    SharedPreferences? prefs,
    DateTime Function()? now,
  }) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    if (!(p.getBool(prefsKey) ?? false)) {
      return null;
    }

    final currentTime = (now ?? DateTime.now)();
    final fireTime = trialEnd.subtract(leadTime);
    if (!fireTime.isAfter(currentTime.add(const Duration(hours: 1)))) {
      return null;
    }

    final s = service ?? DfReminderService();
    await s.init();

    final reminder = DfReminder(
      id: id ?? defaultId,
      title: title ?? strings.title,
      body: body ?? strings.body,
      scheduledAt: fireTime,
      repeat: DfReminderRepeat.none,
      channel: channel,
      payload: payload,
    );

    await s.schedule(reminder);
    return reminder;
  }

  /// Cancels any scheduled trial-ending reminder.
  static Future<void> cancel({
    int? id,
    DfReminderService? service,
  }) async {
    final s = service ?? DfReminderService();
    await s.init();
    await s.cancel(id ?? defaultId);
  }
}
