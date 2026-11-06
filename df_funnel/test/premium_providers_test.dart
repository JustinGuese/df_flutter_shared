import 'dart:async';

import 'package:df_billing/df_billing.dart';
import 'package:df_firebase_auth/df_firebase_auth.dart';
import 'package:df_funnel/src/premium_providers.dart';
import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUser extends Fake implements User {
  FakeUser(this.uid);

  @override
  final String uid;
}

class FakeRevenueCatAuthSyncHandler implements DfRevenueCatAuthSyncHandler {
  final List<String> logInCalls = [];
  int isProCalls = 0;
  int restoreCalls = 0;
  int logOutCalls = 0;
  bool isProResult = false;

  @override
  Future<void> logIn(String uid) async {
    logInCalls.add(uid);
  }

  @override
  Future<bool> isPro() async {
    isProCalls++;
    return isProResult;
  }

  @override
  Future<bool> restore() async {
    restoreCalls++;
    return true;
  }

  @override
  Future<void> logOut() async {
    logOutCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('dfEffectivePremiumProvider (OR logic)', () {
    test('returns true when RevenueCat Pro is active, even if signed out', () {
      final container = ProviderContainer(
        overrides: [
          dfRevenueCatIsProProvider.overrideWithValue(true),
          currentUserProvider.overrideWithValue(null),
          dfIsPremiumProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(dfEffectivePremiumProvider), isTrue);
    });

    test('returns true when user is signed in and backend premium is active', () {
      final container = ProviderContainer(
        overrides: [
          dfRevenueCatIsProProvider.overrideWithValue(false),
          currentUserProvider.overrideWithValue(FakeUser('test-uid')),
          dfIsPremiumProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(dfEffectivePremiumProvider), isTrue);
    });

    test(
      'returns false when signed out with backend premium true',
      () {
        final container = ProviderContainer(
          overrides: [
            dfRevenueCatIsProProvider.overrideWithValue(false),
            currentUserProvider.overrideWithValue(null),
            dfIsPremiumProvider.overrideWithValue(true),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(dfEffectivePremiumProvider), isFalse);
      },
    );

    test('returns false when signed in but neither RC nor backend is premium', () {
      final container = ProviderContainer(
        overrides: [
          dfRevenueCatIsProProvider.overrideWithValue(false),
          currentUserProvider.overrideWithValue(FakeUser('test-uid')),
          dfIsPremiumProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(dfEffectivePremiumProvider), isFalse);
    });
  });

  group('dfAuthRevenueCatSyncProvider', () {
    test(
      'signs in: calls logIn(uid), restores if not pro, invalidates sub, fires onSynced once',
      () async {
        final fakeHandler = FakeRevenueCatAuthSyncHandler();
        final authController = StreamController<User?>();
        addTearDown(authController.close);

        int fetchCount = 0;
        int onSyncedCount = 0;

        final container = ProviderContainer(
          overrides: [
            dfRevenueCatAuthSyncHandlerProvider.overrideWithValue(fakeHandler),
            authStateChangesProvider.overrideWith(
              (ref) => authController.stream,
            ),
            dfSubscriptionFetcherProvider.overrideWithValue(() async {
              fetchCount++;
              return const DfSubscriptionStatus.free();
            }),
          ],
        );
        addTearDown(container.dispose);

        // Listen to sync provider and subscription provider
        container.listen(
          dfAuthRevenueCatSyncProvider(
            onSynced: () {
              onSyncedCount++;
            },
          ),
          (_, _) {},
        );
        container.listen(dfSubscriptionProvider, (_, _) {});

        // Initial subscription read
        await container.read(dfSubscriptionProvider.future);
        expect(fetchCount, equals(1));

        // Sign in
        authController.add(FakeUser('user-123'));
        await pumpEventQueue();

        expect(fakeHandler.logInCalls, equals(['user-123']));
        expect(fakeHandler.isProCalls, equals(1));
        expect(fakeHandler.restoreCalls, equals(1));
        expect(onSyncedCount, equals(1));

        // Re-read subscription to verify invalidation caused a new fetch
        await container.read(dfSubscriptionProvider.future);
        expect(fetchCount, equals(2));

        // Re-emitting same user does not trigger onSynced or logIn again
        authController.add(FakeUser('user-123'));
        await pumpEventQueue();

        expect(fakeHandler.logInCalls.length, equals(1));
        expect(onSyncedCount, equals(1));
      },
    );

    test('signs in: does not restore purchases if already pro', () async {
      final fakeHandler = FakeRevenueCatAuthSyncHandler()..isProResult = true;
      final authController = StreamController<User?>();
      addTearDown(authController.close);

      final container = ProviderContainer(
        overrides: [
          dfRevenueCatAuthSyncHandlerProvider.overrideWithValue(fakeHandler),
          authStateChangesProvider.overrideWith(
            (ref) => authController.stream,
          ),
          dfSubscriptionFetcherProvider.overrideWithValue(
            () async => const DfSubscriptionStatus.free(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(dfAuthRevenueCatSyncProvider(), (_, _) {});

      authController.add(FakeUser('pro-user'));
      await pumpEventQueue();

      expect(fakeHandler.logInCalls, equals(['pro-user']));
      expect(fakeHandler.isProCalls, equals(1));
      expect(fakeHandler.restoreCalls, equals(0));
    });

    test('signs out: calls logOut and invalidates subscription provider', () async {
      final fakeHandler = FakeRevenueCatAuthSyncHandler();
      final authController = StreamController<User?>();
      addTearDown(authController.close);

      int fetchCount = 0;

      final container = ProviderContainer(
        overrides: [
          dfRevenueCatAuthSyncHandlerProvider.overrideWithValue(fakeHandler),
          authStateChangesProvider.overrideWith(
            (ref) => authController.stream,
          ),
          dfSubscriptionFetcherProvider.overrideWithValue(() async {
            fetchCount++;
            return const DfSubscriptionStatus(
              status: 'active',
              isPremium: true,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      container.listen(dfAuthRevenueCatSyncProvider(), (_, _) {});
      container.listen(dfSubscriptionProvider, (_, _) {});

      // Sign in first
      authController.add(FakeUser('user-logout'));
      await pumpEventQueue();
      await container.read(dfSubscriptionProvider.future);
      expect(fakeHandler.logOutCalls, equals(0));
      final initialFetchCount = fetchCount;

      // Set a debug override to verify it resets on sign-out
      container.read(dfDebugPremiumOverrideProvider.notifier).set(true);
      expect(container.read(dfDebugPremiumOverrideProvider), isTrue);

      // Sign out
      authController.add(null);
      await pumpEventQueue();

      expect(fakeHandler.logOutCalls, equals(1));
      expect(container.read(dfDebugPremiumOverrideProvider), isNull);

      // Verify dfSubscriptionProvider was invalidated
      await container.read(dfSubscriptionProvider.future);
      expect(fetchCount, greaterThan(initialFetchCount));
    });
  });
}
