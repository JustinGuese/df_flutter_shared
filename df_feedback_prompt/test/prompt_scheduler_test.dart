import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:df_feedback_prompt/df_feedback_prompt.dart';

void main() {
  group('DfPromptScheduler', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      expect(container.read(dfPromptSchedulerProvider), isNull);
    });

    test('reserves first prompt at any event count', () {
      final notifier = container.read(dfPromptSchedulerProvider.notifier);
      final reserved = notifier.reserve(0);
      expect(reserved, isTrue);
      expect(container.read(dfPromptSchedulerProvider), 0);
    });

    test('rejects prompts within minEventsBetween', () {
      final notifier = container.read(dfPromptSchedulerProvider.notifier);
      expect(notifier.reserve(10), isTrue);
      expect(container.read(dfPromptSchedulerProvider), 10);

      // Default minEventsBetween is 5: 14 - 10 = 4 < 5 -> false
      expect(notifier.reserve(14), isFalse);
      expect(container.read(dfPromptSchedulerProvider), 10);

      // 15 - 10 = 5 >= 5 -> true
      expect(notifier.reserve(15), isTrue);
      expect(container.read(dfPromptSchedulerProvider), 15);
    });

    test('release restores previous state', () {
      final notifier = container.read(dfPromptSchedulerProvider.notifier);
      expect(notifier.reserve(10), isTrue);
      expect(container.read(dfPromptSchedulerProvider), 10);

      // Release first reservation -> null
      notifier.release();
      expect(container.read(dfPromptSchedulerProvider), isNull);

      // Now reserve again at 12 -> succeeds because state was reset to null
      expect(notifier.reserve(12), isTrue);
      expect(container.read(dfPromptSchedulerProvider), 12);

      // Reserve at 20 -> succeeds
      expect(notifier.reserve(20), isTrue);
      expect(container.read(dfPromptSchedulerProvider), 20);

      // Release -> returns to 12
      notifier.release();
      expect(container.read(dfPromptSchedulerProvider), 12);
    });

    test('custom minEventsBetween via provider and reserve parameter', () {
      final customProvider = NotifierProvider<DfPromptScheduler, int?>(
        () => DfPromptScheduler(minEventsBetween: 10),
      );
      final notifier = container.read(customProvider.notifier);
      expect(notifier.reserve(0), isTrue);
      expect(notifier.reserve(5), isFalse);
      expect(notifier.reserve(10), isTrue);

      // Override via parameter
      expect(notifier.reserve(12, minEventsBetween: 2), isTrue);
    });

    test('dfPromptSchedulerFamily configures minEventsBetween', () {
      final notifier = container.read(dfPromptSchedulerFamily(8).notifier);
      expect(notifier.reserve(0), isTrue);
      expect(notifier.reserve(7), isFalse);
      expect(notifier.reserve(8), isTrue);
    });
  });
}
