import 'package:df_notifications/df_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfReminderSchedule.nextOccurrence', () {
    test('a future one-shot fires at its own scheduledAt', () {
      final now = DateTime(2026, 1, 1, 8, 0);
      final reminder = DfReminder(
        id: 1,
        title: 't',
        body: 'b',
        scheduledAt: DateTime(2026, 1, 1, 9, 0),
      );
      expect(
        DfReminderSchedule.nextOccurrence(reminder, now),
        reminder.scheduledAt,
      );
    });

    test('a past one-shot is dropped, not rolled forward', () {
      final now = DateTime(2026, 1, 2, 8, 0);
      final reminder = DfReminder(
        id: 1,
        title: 't',
        body: 'b',
        scheduledAt: DateTime(2026, 1, 1, 9, 0),
      );
      expect(DfReminderSchedule.nextOccurrence(reminder, now), isNull);
    });
  });

  group('nextDaily', () {
    test('today if the time has not passed yet', () {
      final now = DateTime(2026, 1, 1, 8, 0);
      final anchor = DateTime(2020, 1, 1, 9, 0); // only hour/minute matter
      expect(
        DfReminderSchedule.nextDaily(now, anchor),
        DateTime(2026, 1, 1, 9, 0),
      );
    });

    test('tomorrow if the time already passed today', () {
      final now = DateTime(2026, 1, 1, 10, 0);
      final anchor = DateTime(2020, 1, 1, 9, 0);
      expect(
        DfReminderSchedule.nextDaily(now, anchor),
        DateTime(2026, 1, 2, 9, 0),
      );
    });

    test(
      'exact time-of-day match rolls to tomorrow (not-after, not before)',
      () {
        final now = DateTime(2026, 1, 1, 9, 0);
        final anchor = DateTime(2020, 1, 1, 9, 0);
        expect(
          DfReminderSchedule.nextDaily(now, anchor),
          DateTime(2026, 1, 2, 9, 0),
        );
      },
    );
  });

  group('nextWeekly', () {
    test('rolls forward to the anchor weekday within the same week', () {
      // 2026-01-01 is a Thursday (weekday 4). Anchor is a Saturday (6) at 9:00.
      final now = DateTime(2026, 1, 1, 8, 0);
      final anchor = DateTime(2026, 1, 3, 9, 0);
      expect(anchor.weekday, DateTime.saturday);
      final next = DfReminderSchedule.nextWeekly(now, anchor);
      expect(next.weekday, DateTime.saturday);
      expect(next, DateTime(2026, 1, 3, 9, 0));
    });

    test(
      'rolls a full week when today is the anchor weekday but time passed',
      () {
        // 2026-01-01 is a Thursday; anchor is also a Thursday at 9:00, but it's
        // already 10:00, so the next occurrence must be 7 days out.
        final now = DateTime(2026, 1, 1, 10, 0);
        final anchor = DateTime(2020, 1, 2, 9, 0); // any Thursday
        expect(anchor.weekday, DateTime.thursday);
        final next = DfReminderSchedule.nextWeekly(now, anchor);
        expect(next, DateTime(2026, 1, 8, 9, 0));
      },
    );
  });

  group('nextMonthly', () {
    test('this month if the day/time has not passed yet', () {
      final now = DateTime(2026, 1, 1, 8, 0);
      final anchor = DateTime(2020, 3, 15, 9, 0);
      expect(
        DfReminderSchedule.nextMonthly(now, anchor),
        DateTime(2026, 1, 15, 9, 0),
      );
    });

    test('next month if the day/time already passed this month', () {
      final now = DateTime(2026, 1, 20, 8, 0);
      final anchor = DateTime(2020, 3, 15, 9, 0);
      expect(
        DfReminderSchedule.nextMonthly(now, anchor),
        DateTime(2026, 2, 15, 9, 0),
      );
    });

    test('clamps a day-of-month that does not exist in a shorter month', () {
      // Anchor on the 31st; February 2026 only has 28 days.
      final now = DateTime(2026, 2, 1, 8, 0);
      final anchor = DateTime(2020, 1, 31, 9, 0);
      expect(
        DfReminderSchedule.nextMonthly(now, anchor),
        DateTime(2026, 2, 28, 9, 0),
      );
    });

    test('rolls from December into January of the next year', () {
      final now = DateTime(2026, 12, 20, 8, 0);
      final anchor = DateTime(2020, 1, 15, 9, 0);
      expect(
        DfReminderSchedule.nextMonthly(now, anchor),
        DateTime(2027, 1, 15, 9, 0),
      );
    });
  });
}
