import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'df_notification_ids.dart';
import 'df_reminder.dart';
import 'df_reminder_schedule.dart';
import 'df_reminder_service.dart';

/// User-facing copy for the daily reminder.
@immutable
class DfDailyReminderStrings {
  const DfDailyReminderStrings({
    this.title = 'Daily reminder',
    this.body = 'Take a moment to check in today.',
  });

  final String title;
  final String body;
}

/// Controller for scheduling and cancelling a repeating daily reminder.
///
/// Idempotent: re-scheduling with the same [id] replaces any previous
/// schedule in [DfReminderService].
class DfDailyReminder {
  DfDailyReminder({
    int? id,
    this.hour = 8,
    this.minute = 0,
    this.title,
    this.body,
    this.payload = 'daily_reminder',
    this.prefsKey,
    this.channel = DfNotificationChannel.defaultChannel,
    this.strings = const DfDailyReminderStrings(),
    this.service,
    this.now,
  }) : id = id ?? DfNotificationIds.slot(0);

  /// Notification id. Defaults to slot 0 in [DfNotificationIds].
  final int id;

  /// Hour of the day (0-23) when the reminder should fire.
  final int hour;

  /// Minute of the hour (0-59) when the reminder should fire.
  final int minute;

  /// Optional override for the notification title. Defaults to [strings.title].
  final String? title;

  /// Optional override for the notification body. Defaults to [strings.body].
  final String? body;

  /// Notification tap payload.
  final String? payload;

  /// SharedPreferences key that tracks whether this reminder is enabled.
  final String? prefsKey;

  /// Android notification channel.
  final DfNotificationChannel channel;

  /// Fallback copy strings.
  final DfDailyReminderStrings strings;

  /// Pluggable reminder service, mainly for tests.
  final DfReminderService? service;

  /// Clock provider, mainly for deterministic tests.
  final DateTime Function()? now;

  String get effectiveTitle => title ?? strings.title;
  String get effectiveBody => body ?? strings.body;

  /// Schedules the repeating daily reminder for its next occurrence.
  ///
  /// Safe to call repeatedly on launch while enabled (idempotent).
  Future<DfReminder> ensure({DfReminderService? service}) async {
    final s = service ?? this.service ?? DfReminderService();
    await s.init();

    final currentTime = (now ?? DateTime.now)();
    final anchor = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      hour,
      minute,
    );
    final first = DfReminderSchedule.nextDaily(currentTime, anchor);

    final reminder = DfReminder(
      id: id,
      title: effectiveTitle,
      body: effectiveBody,
      scheduledAt: first,
      repeat: DfReminderRepeat.daily,
      channel: channel,
      payload: payload,
    );

    await s.schedule(reminder);
    return reminder;
  }

  /// Cancels the scheduled daily reminder.
  Future<void> cancel({DfReminderService? service}) async {
    final s = service ?? this.service ?? DfReminderService();
    await s.init();
    await s.cancel(id);
  }

  /// Re-arms the reminder if the boolean preference in [prefsKey] is true.
  ///
  /// Returns `true` if scheduled, or `false` if the preference was false or unset.
  Future<bool> restoreIfEnabled([
    String? prefsKey,
    SharedPreferences? prefs,
    DfReminderService? service,
  ]) async {
    final key = prefsKey ?? this.prefsKey;
    if (key == null) {
      throw ArgumentError.notNull('prefsKey');
    }
    final p = prefs ?? await SharedPreferences.getInstance();
    if (p.getBool(key) ?? false) {
      await ensure(service: service);
      return true;
    }
    return false;
  }
}
