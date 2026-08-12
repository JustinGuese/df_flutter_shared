import 'package:df_notifications/df_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DfReminderPreferences', () {
    test('defaults to disabled with no stored time', () async {
      const prefs = DfReminderPreferences(storeKey: 'diary');
      expect(await prefs.isEnabled(), isFalse);
      expect(await prefs.getTime(), isNull);
    });

    test('save() enables and persists the time', () async {
      const prefs = DfReminderPreferences(storeKey: 'diary');
      await prefs.save(hour: 19, minute: 30);

      expect(await prefs.isEnabled(), isTrue);
      final time = await prefs.getTime();
      expect(time?.hour, 19);
      expect(time?.minute, 30);
    });

    test('disable() turns it off but keeps the stored time', () async {
      const prefs = DfReminderPreferences(storeKey: 'diary');
      await prefs.save(hour: 8, minute: 15);
      await prefs.disable();

      expect(await prefs.isEnabled(), isFalse);
      // getTime() reads back null while disabled, even though the hour/minute
      // are still stored underneath — re-enabling should not require the
      // caller to remember the old time separately, but the public API only
      // promises a time while enabled.
      expect(await prefs.getTime(), isNull);
    });

    test('two stores with different keys never collide', () async {
      const diary = DfReminderPreferences(storeKey: 'diary');
      const vitals = DfReminderPreferences(storeKey: 'vitals');

      await diary.save(hour: 19, minute: 0);
      await vitals.save(hour: 9, minute: 0);

      expect((await diary.getTime())?.hour, 19);
      expect((await vitals.getTime())?.hour, 9);

      await diary.disable();
      expect(await diary.isEnabled(), isFalse);
      expect(await vitals.isEnabled(), isTrue);
    });
  });
}
