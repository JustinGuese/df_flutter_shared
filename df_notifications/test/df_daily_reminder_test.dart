import 'package:df_notifications/df_notifications.dart';
import 'package:df_notifications/src/df_daily_reminder.dart';
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

  group('DfDailyReminder', () {
    test('schedules next occurrence and rolls over past reminder hour', () async {
      // 1. Current time is before reminder hour (7:00 vs 8:00) -> fires today at 8:00
      var fakeNow = DateTime(2026, 5, 10, 7, 0);
      final reminder = DfDailyReminder(
        id: 1000,
        hour: 8,
        minute: 0,
        title: 'Morning Brief',
        body: 'Top stories',
        service: service,
        now: () => fakeNow,
      );

      final scheduledToday = await reminder.ensure();
      expect(scheduledToday.scheduledAt, DateTime(2026, 5, 10, 8, 0));
      expect(scheduledToday.repeat, DfReminderRepeat.daily);
      expect(service.scheduled.length, 1);

      // 2. Current time is after reminder hour (9:00 vs 8:00) -> rollover to tomorrow at 8:00
      fakeNow = DateTime(2026, 5, 10, 9, 0);
      final scheduledTomorrow = await reminder.ensure();
      expect(scheduledTomorrow.scheduledAt, DateTime(2026, 5, 11, 8, 0));
      // Idempotent: replaces the existing schedule for id 1000
      expect(service.scheduled.length, 1);
      expect(service.scheduled.first.scheduledAt, DateTime(2026, 5, 11, 8, 0));
    });

    test('restoreIfEnabled is a no-op when pref is disabled or missing', () async {
      final reminder = DfDailyReminder(
        id: 1000,
        service: service,
      );

      // Missing pref -> no-op
      final restoredUnset = await reminder.restoreIfEnabled('notifications_enabled');
      expect(restoredUnset, isFalse);
      expect(service.scheduled, isEmpty);

      // Explicitly disabled pref -> no-op
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
      final restoredDisabled = await reminder.restoreIfEnabled('notifications_enabled');
      expect(restoredDisabled, isFalse);
      expect(service.scheduled, isEmpty);

      // Enabled pref -> schedules
      await prefs.setBool('notifications_enabled', true);
      final restoredEnabled = await reminder.restoreIfEnabled('notifications_enabled');
      expect(restoredEnabled, isTrue);
      expect(service.scheduled.length, 1);
    });

    test('cancel removes scheduled reminder and delegates to service', () async {
      final reminder = DfDailyReminder(
        id: 1000,
        service: service,
      );

      await reminder.ensure();
      expect(service.scheduled.length, 1);

      await reminder.cancel();
      expect(service.cancelled, contains(1000));
      expect(service.scheduled, isEmpty);
    });
  });
}
