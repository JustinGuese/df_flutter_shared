import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/src/prompt_chain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DfPromptChain', () {
    test('shows higher priority prompt before lower priority prompt', () async {
      final shown = <String>[];

      final promptLow = DfPrompt(
        id: 'low',
        priority: 10,
        show: (_) {
          shown.add('low');
          return true;
        },
      );

      final promptHigh = DfPrompt(
        id: 'high',
        priority: 20,
        show: (_) {
          shown.add('high');
          return true;
        },
      );

      // Pass low first in list, but high has higher priority
      final chain = DfPromptChain([promptLow, promptHigh]);

      final result = await chain.run(5);

      expect(result, isTrue);
      expect(shown, equals(['high']));
    });

    test('preserves list order when prompts have equal priority', () async {
      final shown = <String>[];

      final prompt1 = DfPrompt(
        id: 'p1',
        priority: 5,
        show: (_) {
          shown.add('p1');
          return true;
        },
      );

      final prompt2 = DfPrompt(
        id: 'p2',
        priority: 5,
        show: (_) {
          shown.add('p2');
          return true;
        },
      );

      final chain = DfPromptChain([prompt1, prompt2]);
      final result = await chain.run(5);

      expect(result, isTrue);
      expect(shown, equals(['p1']));
    });

    test('shows only one prompt per event and respects scheduler spacing', () async {
      final shown = <String>[];

      final chain = DfPromptChain(
        [
          DfPrompt(
            id: 'first',
            priority: 10,
            show: (_) {
              shown.add('first');
              return true;
            },
          ),
          DfPrompt(
            id: 'second',
            priority: 5,
            show: (_) {
              shown.add('second');
              return true;
            },
          ),
        ],
        scheduler: DfPromptScheduler(minEventsBetween: 5),
      );

      // Event 5: first prompt should show, exactly one prompt displayed
      final r1 = await chain.run(5);
      expect(r1, isTrue);
      expect(shown, equals(['first']));

      // Event 6: less than 5 events since last prompt (5), so scheduler blocks
      final r2 = await chain.run(6);
      expect(r2, isFalse);
      expect(shown, equals(['first']));

      // Event 10: 5 events have elapsed (10 - 5 >= 5), so next prompt can show
      final r3 = await chain.run(10);
      expect(r3, isTrue);
      expect(shown, equals(['first', 'first']));
    });

    test('cooldown blocks repeated prompt display until expired', () async {
      final shown = <String>[];
      const cooldownKey = 'test_cooldown_key';
      const cooldownDuration = Duration(days: 7);

      final primaryPrompt = DfPrompt(
        id: 'primary',
        priority: 10,
        cooldown: const DfCooldown(key: cooldownKey, duration: cooldownDuration),
        show: (_) {
          shown.add('primary');
          return true;
        },
      );

      final fallbackPrompt = DfPrompt(
        id: 'fallback',
        priority: 5,
        show: (_) {
          shown.add('fallback');
          return true;
        },
      );

      final chain = DfPromptChain(
        [primaryPrompt, fallbackPrompt],
        scheduler: DfPromptScheduler(minEventsBetween: 5),
      );

      // First run at event 5: primary should show and mark cooldown
      final r1 = await chain.run(5);
      expect(r1, isTrue);
      expect(shown, equals(['primary']));

      // Second run at event 10 (scheduler allows it): primary is blocked by cooldown,
      // fallback should show instead
      final r2 = await chain.run(10);
      expect(r2, isTrue);
      expect(shown, equals(['primary', 'fallback']));

      // If cooldown is reset, primary is eligible again at event 15
      await const DfCooldown(key: cooldownKey, duration: cooldownDuration).reset();
      final r3 = await chain.run(15);
      expect(r3, isTrue);
      expect(shown, equals(['primary', 'fallback', 'primary']));
    });

    test('releases reservation if prompt declines to show', () async {
      final shown = <String>[];

      final decliningPrompt = DfPrompt(
        id: 'declining',
        priority: 10,
        show: (_) => false, // Decided not to show
      );

      final fallbackPrompt = DfPrompt(
        id: 'fallback',
        priority: 5,
        show: (_) {
          shown.add('fallback');
          return true;
        },
      );

      final chain = DfPromptChain(
        [decliningPrompt, fallbackPrompt],
        scheduler: DfPromptScheduler(minEventsBetween: 5),
      );

      final result = await chain.run(5);
      expect(result, isTrue);
      // Declining prompt ran but returned false, releasing its reservation,
      // allowing fallback prompt to be reserved and shown
      expect(shown, equals(['fallback']));
      expect(chain.scheduler.state, equals(5));
    });

    test('respects minEvents and canShow predicate', () async {
      var allowSpecial = false;

      final chain = DfPromptChain([
        DfPrompt(
          id: 'needs_10',
          minEvents: 10,
          show: (_) => true,
        ),
        DfPrompt(
          id: 'needs_flag',
          canShow: (_) => allowSpecial,
          show: (_) => true,
        ),
      ]);

      // Event 5: minEvents 10 not reached, allowSpecial false -> nothing shown
      expect(await chain.run(5), isFalse);

      // Event 10: minEvents reached -> shown
      expect(await chain.run(10), isTrue);

      allowSpecial = true;
      // Event 15: canShow true -> shown
      expect(await chain.run(15), isTrue);
    });

    test('works with Riverpod ProviderContainer notifier', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final scheduler = container.read(dfPromptSchedulerFamily(3).notifier);
      final chain = DfPromptChain(
        [
          DfPrompt(
            id: 'p',
            show: (_) => true,
          ),
        ],
        scheduler: scheduler,
      );

      expect(await chain.run(1), isTrue);
      expect(container.read(dfPromptSchedulerFamily(3)), 1);

      // Blocked at 3 (3 - 1 = 2 < 3)
      expect(await chain.run(3), isFalse);

      // Allowed at 4 (4 - 1 = 3 >= 3)
      expect(await chain.run(4), isTrue);
      expect(container.read(dfPromptSchedulerFamily(3)), 4);
    });
  });
}
