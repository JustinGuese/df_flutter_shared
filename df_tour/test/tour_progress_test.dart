import 'package:df_tour/df_tour.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _step1 = TourStep(id: 'profile', title: 'Profile', body: 'Why profile');
const _step2 = TourStep(id: 'topics', title: 'Topics', body: 'Why topics');
const _step3 = TourStep(id: 'support', title: 'Support', body: 'Why support');
const _steps = [_step1, _step2, _step3];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TourProgress (pure)', () {
    test('isDone falls back to visited when there is no override', () {
      final visited = {'profile'};
      expect(TourProgress.isDone(_step1, visited), isTrue);
      expect(TourProgress.isDone(_step2, visited), isFalse);
    });

    test('isDone lets an override win for its step, and only its step', () {
      final visited = <String>{};
      bool? override(TourStep step) => step.id == 'profile' ? true : null;

      expect(
        TourProgress.isDone(_step1, visited, isDoneOverride: override),
        isTrue,
      );
      // Other steps fall back to visited (which is empty) since the override
      // returned null for them.
      expect(
        TourProgress.isDone(_step2, visited, isDoneOverride: override),
        isFalse,
      );
    });

    test('an override can also mark a visited step as not-done', () {
      final visited = {'profile'};
      bool? override(TourStep step) => step.id == 'profile' ? false : null;
      expect(
        TourProgress.isDone(_step1, visited, isDoneOverride: override),
        isFalse,
      );
    });

    test('doneCount counts only complete steps', () {
      final visited = {'profile', 'support'};
      expect(TourProgress.doneCount(_steps, visited), 2);
    });

    test('remaining returns incomplete steps in declaration order', () {
      final visited = {'profile'};
      expect(TourProgress.remaining(_steps, visited), [_step2, _step3]);
    });

    test('remaining is empty once every step is done', () {
      final visited = {'profile', 'topics', 'support'};
      expect(TourProgress.remaining(_steps, visited), isEmpty);
    });

    test('nextStep is the first incomplete step', () {
      final visited = {'profile'};
      expect(TourProgress.nextStep(_steps, visited), _step2);
    });

    test('nextStep is null once every step is done', () {
      final visited = {'profile', 'topics', 'support'};
      expect(TourProgress.nextStep(_steps, visited), isNull);
    });

    test('nextStep respects an override even for a visited step', () {
      // A "do" step the app's own data says is NOT actually done yet, even
      // though the tour marked it visited.
      final visited = {'profile', 'topics', 'support'};
      bool? override(TourStep step) => step.id == 'profile' ? false : null;
      expect(
        TourProgress.nextStep(_steps, visited, isDoneOverride: override),
        _step1,
      );
    });
  });

  group('TourProgressNotifier persistence', () {
    ProviderContainer containerWith(Map<String, Object> stored) {
      SharedPreferences.setMockInitialValues(stored);
      return ProviderContainer();
    }

    /// The notifier loads from disk asynchronously, so give it a turn.
    Future<TourProgressNotifier> loaded(ProviderContainer c) async {
      final notifier = c.read(tourProgressProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      return notifier;
    }

    test('starts unseen with no visited steps before loading', () {
      final c = containerWith({});
      addTearDown(c.dispose);
      final state = c.read(tourProgressProvider);
      expect(state.loaded, isFalse);
      expect(state.seen, isFalse);
      expect(state.visited, isEmpty);
    });

    test('reads back "seen" written by a previous session', () async {
      final c = containerWith({'df_tour_seen': true});
      addTearDown(c.dispose);
      await loaded(c);
      final state = c.read(tourProgressProvider);
      expect(state.loaded, isTrue);
      expect(state.seen, isTrue);
    });

    test('markSeen persists and is idempotent', () async {
      final c = containerWith({});
      addTearDown(c.dispose);
      final notifier = await loaded(c);

      await notifier.markSeen();
      expect(c.read(tourProgressProvider).seen, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('df_tour_seen'), isTrue);

      // Calling again must not throw or flip state back.
      await notifier.markSeen();
      expect(c.read(tourProgressProvider).seen, isTrue);
    });

    test('markVisited persists under the step\'s storage key', () async {
      final c = containerWith({});
      addTearDown(c.dispose);
      final notifier = await loaded(c);

      await notifier.markVisited(_step1);
      expect(c.read(tourProgressProvider).visited, {'profile'});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(_step1.storageKey), isTrue);
      expect(_step1.storageKey, 'df_tour_step_profile');
    });

    test(
      'hydrate reads back visited flags written by a previous session',
      () async {
        final c = containerWith({
          _step1.storageKey: true,
          _step3.storageKey: true,
        });
        addTearDown(c.dispose);
        final notifier = await loaded(c);

        // Before hydrate(), a fresh notifier has no way to know these keys
        // exist — it doesn't know the step list yet.
        expect(c.read(tourProgressProvider).visited, isEmpty);

        await notifier.hydrate(_steps);
        expect(c.read(tourProgressProvider).visited, {'profile', 'support'});
      },
    );

    test(
      'reset clears seen and every listed step, but not other prefs',
      () async {
        final c = containerWith({
          'df_tour_seen': true,
          _step1.storageKey: true,
          _step2.storageKey: true,
          'unrelated_key': true,
        });
        addTearDown(c.dispose);
        final notifier = await loaded(c);
        await notifier.hydrate(_steps);
        expect(c.read(tourProgressProvider).visited, {'profile', 'topics'});

        await notifier.reset(_steps);

        final state = c.read(tourProgressProvider);
        expect(state.seen, isFalse);
        expect(state.visited, isEmpty);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('df_tour_seen'), isNull);
        expect(prefs.getBool(_step1.storageKey), isNull);
        expect(prefs.getBool('unrelated_key'), isTrue);
      },
    );
  });
}
