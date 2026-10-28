import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:df_feedback_prompt/df_feedback_prompt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DfCooldown', () {
    const key = 'test_cooldown_key';
    const duration = Duration(days: 7);
    late DfCooldown cooldown;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cooldown = const DfCooldown(key: key, duration: duration);
    });

    test('isReady is true initially when key is not set', () async {
      expect(await cooldown.isReady(), isTrue);
      expect(await cooldown.lastMarked(), isNull);
    });

    test('mark stores current time and makes isReady false', () async {
      await cooldown.mark();
      expect(await cooldown.isReady(), isFalse);
      expect(await cooldown.lastMarked(), isNotNull);
    });

    test('isReady is true after duration has elapsed', () async {
      final past = DateTime.now().subtract(const Duration(days: 8));
      await cooldown.mark(now: past);
      expect(await cooldown.isReady(), isTrue);
    });

    test('isReady is false before duration has elapsed', () async {
      final recent = DateTime.now().subtract(const Duration(days: 6));
      await cooldown.mark(now: recent);
      expect(await cooldown.isReady(), isFalse);
    });

    test('reset clears the stored timestamp', () async {
      await cooldown.mark();
      expect(await cooldown.isReady(), isFalse);
      await cooldown.reset();
      expect(await cooldown.isReady(), isTrue);
      expect(await cooldown.lastMarked(), isNull);
    });
  });
}
