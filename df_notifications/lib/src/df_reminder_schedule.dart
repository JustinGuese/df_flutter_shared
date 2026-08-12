import 'df_reminder.dart';

/// Pure "what's the next fire time" math, shared by the native and web
/// implementations (and directly unit-testable without either plugin).
///
/// Native scheduling still leans on `flutter_local_notifications`'
/// `matchDateTimeComponents` to keep recurring reminders firing without the
/// app reopening, but the *first* occurrence must already be in the future —
/// these functions compute that first (or next, for web's session-only
/// timers) occurrence from a possibly-past anchor.
abstract final class DfReminderSchedule {
  /// The next fire time for [reminder] at or after [now]. Returns `null` for
  /// a [DfReminderRepeat.none] reminder whose `scheduledAt` has already
  /// passed — one-shots are never rolled forward, they are simply dropped,
  /// matching how a missed one-shot (e.g. a win-back nudge) should behave.
  static DateTime? nextOccurrence(DfReminder reminder, DateTime now) {
    final anchor = reminder.scheduledAt;
    switch (reminder.repeat) {
      case DfReminderRepeat.none:
        return anchor.isAfter(now) ? anchor : null;
      case DfReminderRepeat.daily:
        return nextDaily(now, anchor);
      case DfReminderRepeat.weekly:
        return nextWeekly(now, anchor);
      case DfReminderRepeat.monthly:
        return nextMonthly(now, anchor);
    }
  }

  /// Next time-of-day match of [anchor]'s hour/minute at or after [now].
  static DateTime nextDaily(DateTime now, DateTime anchor) {
    var candidate = DateTime(
      now.year,
      now.month,
      now.day,
      anchor.hour,
      anchor.minute,
    );
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Next occurrence of [anchor]'s weekday + time-of-day at or after [now].
  static DateTime nextWeekly(DateTime now, DateTime anchor) {
    var candidate = DateTime(
      now.year,
      now.month,
      now.day,
      anchor.hour,
      anchor.minute,
    );
    // Dart's `%` on a positive divisor is always non-negative, so this rolls
    // forward (or stays put) regardless of which weekday `now` falls on.
    final daysUntilWeekday = (anchor.weekday - candidate.weekday) % 7;
    candidate = candidate.add(Duration(days: daysUntilWeekday));
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }

  /// Next occurrence of [anchor]'s day-of-month + time-of-day at or after
  /// [now]. The day is clamped to the last day of a shorter month (e.g. an
  /// anchor on the 31st fires on the 28th/29th in February) so a monthly
  /// reminder never silently skips a month.
  static DateTime nextMonthly(DateTime now, DateTime anchor) {
    DateTime candidateFor(int year, int month) {
      final day = _clampDay(year, month, anchor.day);
      return DateTime(year, month, day, anchor.hour, anchor.minute);
    }

    var candidate = candidateFor(now.year, now.month);
    if (!candidate.isAfter(now)) {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final year = now.month == 12 ? now.year + 1 : now.year;
      candidate = candidateFor(year, nextMonth);
    }
    return candidate;
  }

  static int _clampDay(int year, int month, int day) {
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    return day > lastDayOfMonth ? lastDayOfMonth : day;
  }
}
