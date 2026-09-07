import 'package:df_analytics/df_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tracker = DfRetentionTracker.instance;
  const config = DfRetentionConfig();

  /// Pins the tracker's clock to a fixed calendar day.
  void setToday(String stamp) {
    final date = DateTime.parse(stamp);
    tracker.now = () => DateTime(date.year, date.month, date.day, 12);
  }

  /// The milestone events reported so far, read back from the fire-once guard
  /// rather than from Firebase — the analytics call itself is a no-op without
  /// a Firebase binding, but the guard is what makes the events idempotent.
  Future<List<String>> firedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${config.keyPrefix}_fired') ?? <String>[];
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tracker.now = DateTime.now;
  });

  tearDown(() => tracker.now = DateTime.now);

  group('recordAppOpen', () {
    test('reports no milestone on the first day', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();

      expect(await firedEvents(), isEmpty);
      expect(await tracker.activeDayCount(), 1);
      expect(await tracker.firstOpenDate(), DateTime(2026, 1, 1));
    });

    test('reports a milestone once the day is reached', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();

      setToday('2026-01-02');
      await tracker.recordAppOpen();

      expect(await firedEvents(), ['Retention_D1']);
    });

    test('does not report the same milestone twice', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();

      setToday('2026-01-02');
      await tracker.recordAppOpen();
      await tracker.recordAppOpen();
      await tracker.recordAppOpen();

      expect(await firedEvents(), ['Retention_D1']);
    });

    test('counts one active day however many times it opens', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();
      await tracker.recordAppOpen();

      expect(await tracker.activeDayCount(), 1);
    });

    test('reports skipped milestones on a late return', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();

      // Away for a week, so D1, D2, D3 and D7 all became true unobserved.
      setToday('2026-01-08');
      await tracker.recordAppOpen();

      expect(await firedEvents(), [
        'Retention_D1',
        'Retention_D2',
        'Retention_D3',
        'Retention_D7',
      ]);
    });

    test('measures elapsed days across a month boundary', () async {
      setToday('2026-01-30');
      await tracker.recordAppOpen();

      setToday('2026-02-02');
      await tracker.recordAppOpen();

      expect(await firedEvents(), contains('Retention_D3'));
      expect(await firedEvents(), isNot(contains('Retention_D7')));
    });
  });

  group('currentStreak', () {
    test('is zero before any open', () async {
      expect(await tracker.currentStreak(), 0);
    });

    test('counts consecutive days ending today', () async {
      for (final day in ['2026-01-01', '2026-01-02', '2026-01-03']) {
        setToday(day);
        await tracker.recordAppOpen();
      }

      expect(await tracker.currentStreak(), 3);
    });

    test('survives a day that has not been opened yet', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();
      setToday('2026-01-02');
      await tracker.recordAppOpen();

      // Third day, app not opened yet: yesterday still anchors the streak.
      setToday('2026-01-03');
      expect(await tracker.currentStreak(), 2);
    });

    test('resets after a missed day', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();
      setToday('2026-01-02');
      await tracker.recordAppOpen();

      // 3 January missed entirely.
      setToday('2026-01-04');
      await tracker.recordAppOpen();

      expect(await tracker.currentStreak(), 1);
    });

    test('counts a streak spanning a month boundary', () async {
      for (final day in ['2026-01-30', '2026-01-31', '2026-02-01']) {
        setToday(day);
        await tracker.recordAppOpen();
      }

      expect(await tracker.currentStreak(), 3);
    });
  });

  group('recordMilestoneAction', () {
    test('reports only at the named thresholds', () async {
      Future<void> record() => tracker.recordMilestoneAction(
        actionKey: 'thing',
        milestones: const [1, 3],
        eventName: 'Activated',
      );

      await record();
      expect(await firedEvents(), ['Activated_1']);

      await record();
      expect(await firedEvents(), ['Activated_1']);

      await record();
      expect(await firedEvents(), ['Activated_1', 'Activated_3']);
    });

    test('counts each action key separately', () async {
      await tracker.recordMilestoneAction(
        actionKey: 'a',
        milestones: const [1],
        eventName: 'A',
      );
      await tracker.recordMilestoneAction(
        actionKey: 'b',
        milestones: const [1],
        eventName: 'B',
      );

      expect(await firedEvents(), ['A_1', 'B_1']);
    });
  });

  group('reset', () {
    test('clears first open, active days and fired milestones', () async {
      setToday('2026-01-01');
      await tracker.recordAppOpen();
      setToday('2026-01-02');
      await tracker.recordAppOpen();

      await tracker.reset();

      expect(await tracker.firstOpenDate(), isNull);
      expect(await tracker.activeDayCount(), 0);
      expect(await firedEvents(), isEmpty);
    });
  });

  group('isValidMetaCustomEventName', () {
    test('accepts the names this tracker generates', () {
      expect(isValidMetaCustomEventName('Retention_D7'), isTrue);
      expect(isValidMetaCustomEventName('Activated_3'), isTrue);
    });

    test('rejects empty, overlong and illegally punctuated names', () {
      expect(isValidMetaCustomEventName(''), isFalse);
      expect(isValidMetaCustomEventName('a' * 41), isFalse);
      expect(isValidMetaCustomEventName('has.a.dot'), isFalse);
      expect(isValidMetaCustomEventName('-leading-hyphen'), isFalse);
    });
  });
}
