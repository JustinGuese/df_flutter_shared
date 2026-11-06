import 'package:df_notifications/df_notifications.dart';
import 'package:df_notifications/src/df_trial_ending_reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReminderService implements DfReminderService {
  bool initialized = false;
  final List<DfReminder> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> init() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> schedule(DfReminder reminder) async {
    scheduled.removeWhere((r) => r.id == reminder.id);
    scheduled.add(reminder);
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> cancelMany(Iterable<int> ids) async {
    for (final id in ids) {
      await cancel(id);
    }
  }

  @override
  String? consumePendingPayload() => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeReminderService service;

  setUp(() {
    service = _FakeReminderService();
    SharedPreferences.setMockInitialValues({});
  });

  group('DfTrialEndingReminder', () {
    test('skips scheduling when notifications preference is disabled or missing', () async {
      final now = DateTime(2026, 5, 10, 12, 0);
      final trialEnd = now.add(const Duration(days: 7));

      // 1. Missing pref -> no-op
      final resultUnset = await DfTrialEndingReminder.schedule(
        trialEnd,
        service: service,
        now: () => now,
      );
      expect(resultUnset, isNull);
      expect(service.scheduled, isEmpty);

      // 2. Explicitly disabled pref -> no-op
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
      final resultDisabled = await DfTrialEndingReminder.schedule(
        trialEnd,
        service: service,
        now: () => now,
      );
      expect(resultDisabled, isNull);
      expect(service.scheduled, isEmpty);
    });

    test('skips scheduling when fire time is less than 1 hour away', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);

      final now = DateTime(2026, 5, 10, 12, 0);

      // Fire time is 30 minutes from now (trialEnd is 2 days + 30 mins, minus 2 days lead time)
      final trialEndTooSoon = now.add(const Duration(days: 2, minutes: 30));
      final resultTooSoon = await DfTrialEndingReminder.schedule(
        trialEndTooSoon,
        service: service,
        now: () => now,
      );
      expect(resultTooSoon, isNull);
      expect(service.scheduled, isEmpty);

      // Fire time is exactly 1 hour from now -> still not *after* 1 hour away -> no-op
      final trialEndExact1Hour = now.add(const Duration(days: 2, hours: 1));
      final resultExact = await DfTrialEndingReminder.schedule(
        trialEndExact1Hour,
        service: service,
        now: () => now,
      );
      expect(resultExact, isNull);
      expect(service.scheduled, isEmpty);
    });

    test('schedules reminder when valid and allows cancellation', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);

      final now = DateTime(2026, 5, 10, 12, 0);
      // Trial ends in 3 days, default lead time is 2 days -> fires 1 day from now
      final trialEnd = now.add(const Duration(days: 3));

      final scheduled = await DfTrialEndingReminder.schedule(
        trialEnd,
        service: service,
        now: () => now,
      );

      expect(scheduled, isNotNull);
      expect(scheduled!.scheduledAt, trialEnd.subtract(const Duration(days: 2)));
      expect(scheduled.repeat, DfReminderRepeat.none);
      expect(scheduled.id, DfTrialEndingReminder.defaultId);
      expect(service.scheduled.length, 1);

      // Cancel
      await DfTrialEndingReminder.cancel(service: service);
      expect(service.cancelled, contains(DfTrialEndingReminder.defaultId));
      expect(service.scheduled, isEmpty);
    });
  });
}
