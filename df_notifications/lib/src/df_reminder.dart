import 'package:flutter/foundation.dart';

/// Which recurring components of [DfReminder.scheduledAt] the OS should
/// re-match on every fire.
///
/// [none] is a one-shot: it fires once at [DfReminder.scheduledAt] and is
/// not re-armed. The others repeat forever, anchored to the time-of-day (and,
/// for [weekly]/[monthly], the weekday / day-of-month) already encoded in
/// [DfReminder.scheduledAt] — there is no separate "every N" field, so the
/// anchor date is the single source of truth for when a recurring reminder
/// falls.
enum DfReminderRepeat { none, daily, weekly, monthly }

/// How urgently a channel should interrupt the user. Mirrors the native
/// notion of importance without leaking a plugin type into this pure model.
enum DfNotificationImportance { low, defaultImportance, high }

/// An Android notification channel (ignored on web, which has no channel
/// concept). Group reminders that a user might want to mute independently —
/// e.g. "daily nudges" vs "task due dates" — into separate channels.
@immutable
class DfNotificationChannel {
  const DfNotificationChannel({
    required this.id,
    required this.name,
    this.description = '',
    this.importance = DfNotificationImportance.high,
  });

  /// A single channel every app can use out of the box. Apps with more than
  /// one kind of reminder should define their own so users can mute one
  /// without silencing the rest.
  static const DfNotificationChannel defaultChannel = DfNotificationChannel(
    id: 'df_reminders',
    name: 'Reminders',
    description: 'Scheduled reminders',
  );

  /// Stable Android channel id. Changing it orphans any already-delivered
  /// notifications' settings — treat it like a database column name.
  final String id;

  final String name;
  final String description;
  final DfNotificationImportance importance;
}

/// A single scheduled local notification, platform-agnostic.
///
/// This is the neutral unit apps map their own domain types onto — a task, a
/// diary prompt, a course nudge — rather than the package knowing about any
/// of them. [id] must come from a range the app has reserved for itself; see
/// `DfNotificationIds` for the convention shared reminders use.
@immutable
class DfReminder {
  const DfReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.repeat = DfReminderRepeat.none,
    this.channel = DfNotificationChannel.defaultChannel,
    this.payload,
  });

  /// Notification id. Also used to cancel or replace this reminder later.
  final int id;

  final String title;
  final String body;

  /// The anchor moment. For a one-shot reminder this is when it fires; for a
  /// repeating one it is the *first* occurrence, and its time-of-day (plus
  /// weekday for [DfReminderRepeat.weekly], day-of-month for
  /// [DfReminderRepeat.monthly]) is reused on every subsequent fire.
  final DateTime scheduledAt;

  final DfReminderRepeat repeat;
  final DfNotificationChannel channel;

  /// Opaque string handed back via `DfReminderService.consumePendingPayload`
  /// when the user taps the notification. Use it to route to a screen —
  /// never put anything sensitive in it, it is stored in plain text by the OS.
  final String? payload;

  DfReminder copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? scheduledAt,
    DfReminderRepeat? repeat,
    DfNotificationChannel? channel,
    String? payload,
  }) => DfReminder(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    repeat: repeat ?? this.repeat,
    channel: channel ?? this.channel,
    payload: payload ?? this.payload,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DfReminder &&
          other.id == id &&
          other.title == title &&
          other.body == body &&
          other.scheduledAt == scheduledAt &&
          other.repeat == repeat &&
          other.channel.id == channel.id &&
          other.payload == payload);

  @override
  int get hashCode =>
      Object.hash(id, title, body, scheduledAt, repeat, channel.id, payload);

  @override
  String toString() =>
      'DfReminder(id: $id, title: $title, scheduledAt: $scheduledAt, repeat: $repeat)';
}
