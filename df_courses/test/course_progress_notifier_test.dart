import 'dart:convert';

import 'package:df_courses/df_courses.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The key both the current and the retired course screen wrote to.
const _prefsKey = 'learning_progress_v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer containerWith(Map<String, List<String>> stored) {
    SharedPreferences.setMockInitialValues({
      if (stored.isNotEmpty) _prefsKey: jsonEncode(stored),
    });
    return ProviderContainer();
  }

  /// The notifier loads from disk asynchronously, so give it a turn.
  Future<CourseProgressNotifier> loaded(ProviderContainer c) async {
    final notifier = c.read(courseProgressNotifierProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    return notifier;
  }

  group('CourseProgressIds', () {
    test('quiz and checklist IDs share one convention', () {
      expect(CourseProgressIds.quizPassed('sturz', 'c3'), 'sturz_c3_passed');
      expect(
        CourseProgressIds.checklistItem('sturz', 'c2', 'a'),
        'sturz_c2_item_a',
      );
      // Both must come from item(), or the two call sites can drift apart the
      // way the old course screens did.
      expect(
        CourseProgressIds.item('sturz', 'c3', 'passed'),
        CourseProgressIds.quizPassed('sturz', 'c3'),
      );
    });
  });

  group('persistence', () {
    test('reads back progress written by a previous session', () async {
      final c = containerWith({
        'sturz': ['sturz_c1_item_a', 'sturz_c3_passed'],
      });
      addTearDown(c.dispose);

      final notifier = await loaded(c);
      expect(notifier.completedItemIds('sturz'), {
        'sturz_c1_item_a',
        'sturz_c3_passed',
      });
      expect(notifier.completionRatio('sturz', 4), 0.5);
    });

    test('survives a corrupt blob instead of throwing', () async {
      SharedPreferences.setMockInitialValues({_prefsKey: 'not json at all'});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final notifier = await loaded(c);
      expect(notifier.completedItemIds('sturz'), isEmpty);
    });

    test('markComplete / markIncomplete round-trip to disk', () async {
      final c = containerWith({});
      addTearDown(c.dispose);
      final notifier = await loaded(c);

      await notifier.markComplete('sturz', 'sturz_c1_item_a');
      await notifier.markComplete('sturz', 'sturz_c1_item_b');
      await notifier.markIncomplete('sturz', 'sturz_c1_item_a');

      final prefs = await SharedPreferences.getInstance();
      final stored =
          jsonDecode(prefs.getString(_prefsKey)!) as Map<String, dynamic>;
      expect(stored['sturz'], ['sturz_c1_item_b']);
    });

    test('completionRatio is clamped and safe at zero total', () async {
      final c = containerWith({
        'sturz': ['a', 'b', 'c'],
      });
      addTearDown(c.dispose);
      final notifier = await loaded(c);

      expect(notifier.completionRatio('sturz', 0), 0.0);
      // More stored IDs than the course currently has chapters must not exceed 1.
      expect(notifier.completionRatio('sturz', 2), 1.0);
      expect(notifier.completionRatio('unknown-course', 5), 0.0);
    });
  });

  group('migrateLegacyIds', () {
    test('drops IDs written by the retired df_onboarding screen', () async {
      // The old screen keyed items by section type and position; the current
      // one keys them by chapter id. Both wrote to this same blob.
      final c = containerWith({
        'sturz': [
          'sturz_sofortUmsetzbar_0',
          'sturz_warnsignale_2',
          'sturz_c1_item_a',
          'sturz_c3_passed',
        ],
      });
      addTearDown(c.dispose);
      final notifier = await loaded(c);

      await notifier.migrateLegacyIds({
        CourseProgressIds.checklistItem('sturz', 'c1', 'a'),
        CourseProgressIds.quizPassed('sturz', 'c3'),
      });

      expect(notifier.completedItemIds('sturz'), {
        'sturz_c1_item_a',
        'sturz_c3_passed',
      });
      // The stale IDs were inflating every ratio; four "complete" items against
      // a two-chapter course reported 100% before the migration.
      expect(notifier.completionRatio('sturz', 4), 0.5);
    });

    test('persists the cleaned blob', () async {
      final c = containerWith({
        'sturz': ['sturz_sofortUmsetzbar_0', 'sturz_c1_item_a'],
      });
      addTearDown(c.dispose);
      final notifier = await loaded(c);

      await notifier.migrateLegacyIds({'sturz_c1_item_a'});

      final prefs = await SharedPreferences.getInstance();
      final stored =
          jsonDecode(prefs.getString(_prefsKey)!) as Map<String, dynamic>;
      expect(stored['sturz'], ['sturz_c1_item_a']);
    });

    test('is a no-op when everything is already known', () async {
      final c = containerWith({
        'sturz': ['sturz_c1_item_a'],
      });
      addTearDown(c.dispose);
      final notifier = await loaded(c);

      await notifier.migrateLegacyIds({'sturz_c1_item_a'});
      expect(notifier.completedItemIds('sturz'), {'sturz_c1_item_a'});
    });
  });

  test('mergeFromBackend keeps the union of local and remote', () async {
    final c = containerWith({
      'sturz': ['local_only'],
    });
    addTearDown(c.dispose);
    final notifier = await loaded(c);

    await notifier.mergeFromBackend('sturz', ['remote_only', 'local_only']);

    expect(notifier.completedItemIds('sturz'), {'local_only', 'remote_only'});
  });
}
