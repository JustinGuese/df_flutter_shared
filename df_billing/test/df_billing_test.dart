import 'package:df_billing/df_billing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DfSubscriptionStatus', () {
    test('parses the backend payload', () {
      final s = DfSubscriptionStatus.fromJson({
        'status': 'trialing',
        'is_premium': true,
        'trial_end': '2026-09-01T00:00:00.000Z',
      });
      expect(s.isPremium, isTrue);
      expect(s.isTrialing, isTrue);
      expect(s.trialEnd, isNotNull);
    });

    test('degrades to free rather than throwing on junk', () {
      final s = DfSubscriptionStatus.fromJson({'status': 42, 'trial_end': 7});
      expect(s.isPremium, isFalse);
      expect(s.status, 'free');
      expect(s.trialEnd, isNull);
    });

    test('trialDaysRemaining rounds partial days up', () {
      final now = DateTime.utc(2026, 8, 12, 12);
      final s = DfSubscriptionStatus(
        status: 'trialing',
        isPremium: true,
        trialEnd: now.add(const Duration(hours: 18)),
      );
      // 18 hours left is still "1 day", not 0 — inDays alone would say the
      // trial is already over.
      expect(s.trialDaysRemaining(now: now), 1);
    });

    test('trialDaysRemaining is zero once past, never negative', () {
      final now = DateTime.utc(2026, 8, 12);
      final s = DfSubscriptionStatus(
        status: 'trialing',
        isPremium: false,
        trialEnd: now.subtract(const Duration(days: 3)),
      );
      expect(s.trialDaysRemaining(now: now), 0);
    });

    test('round-trips through json', () {
      const s = DfSubscriptionStatus(status: 'active', isPremium: true);
      expect(DfSubscriptionStatus.fromJson(s.toJson()), s);
    });
  });

  group('DfCheckoutLinks', () {
    const links = DfCheckoutLinks(
      live: {'subscription': 'https://live/sub', 'review': ''},
      test: {'subscription': 'https://test/sub', 'review': 'https://test/rev'},
    );

    test('falls back to the test URL when the live one is unconfigured', () {
      // A half-configured funnel should open a working test page rather than
      // a blank Stripe error.
      expect(links.url('review'), 'https://test/rev');
    });

    test('returns null when neither is configured', () {
      const empty = DfCheckoutLinks(live: {}, test: {});
      expect(empty.url('subscription'), isNull);
      expect(empty.has('subscription'), isFalse);
    });

    test('isTestEnvironment forces the test set', () {
      const staging = DfCheckoutLinks(
        live: {'subscription': 'https://live/sub'},
        test: {'subscription': 'https://test/sub'},
        isTestEnvironment: _alwaysTrue,
      );
      expect(staging.url('subscription'), 'https://test/sub');
    });
  });

  group('DfCheckout.buildUrl', () {
    test('encodes uid and product slug for the webhook', () {
      final uri = DfCheckout.buildUrl(
        url: 'https://buy.stripe.com/abc',
        userId: 'uid123',
        productSlug: 'antrag_review',
        email: 'a@b.de',
      );
      expect(
        uri.queryParameters['client_reference_id'],
        'uid123|antrag_review',
      );
      expect(uri.queryParameters['prefilled_email'], 'a@b.de');
    });

    test('omits the slug separator when there is no product', () {
      final uri = DfCheckout.buildUrl(
        url: 'https://buy.stripe.com/abc',
        userId: 'uid123',
      );
      expect(uri.queryParameters['client_reference_id'], 'uid123');
    });

    test('preserves query params already on the link', () {
      final uri = DfCheckout.buildUrl(
        url: 'https://buy.stripe.com/abc?locale=de',
        userId: 'uid123',
      );
      expect(uri.queryParameters['locale'], 'de');
    });
  });

  group('DfCheckout.open', () {
    test('refuses to open an unattributable checkout', () async {
      final result = await DfCheckout.open(
        url: 'https://buy.stripe.com/abc',
        userId: null,
      );
      // Taking money the backend cannot match to a user is worse than not
      // taking it — the app must register them first.
      expect(result.failure, DfCheckoutFailure.authRequired);
    });

    test('reports a missing link rather than opening nothing', () async {
      final result = await DfCheckout.open(url: null, userId: 'uid123');
      expect(result.failure, DfCheckoutFailure.notConfigured);
    });
  });

  group('DfSubscriptionNotifier entitlement caching', () {
    ProviderContainer containerWith(DfSubscriptionFetcher fetcher) {
      final c = ProviderContainer(
        overrides: [dfSubscriptionFetcherProvider.overrideWithValue(fetcher)],
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('premium survives a backend outage', () async {
      var shouldFail = false;
      final c = containerWith(() async {
        if (shouldFail) throw Exception('network down');
        return const DfSubscriptionStatus(status: 'active', isPremium: true);
      });

      await c.read(dfSubscriptionProvider.future);
      expect(c.read(dfIsPremiumProvider), isTrue);

      shouldFail = true;
      await c.read(dfSubscriptionProvider.notifier).refresh();

      // The regression this guards: dropping to free on a network blip locks
      // paying users out of content they already bought.
      expect(c.read(dfIsPremiumProvider), isTrue);
    });

    test('an unknown user with no cache is not granted premium', () async {
      final c = containerWith(() async => throw Exception('network down'));
      await c.read(dfSubscriptionProvider.future);
      expect(c.read(dfIsPremiumProvider), isFalse);
    });

    test('a cached premium status survives a cold start', () async {
      final first = containerWith(
        () async =>
            const DfSubscriptionStatus(status: 'active', isPremium: true),
      );
      await first.read(dfSubscriptionProvider.future);

      // New container, same device storage, backend unreachable.
      final second = containerWith(() async => throw Exception('offline'));
      await second.read(dfSubscriptionProvider.future);
      expect(second.read(dfIsPremiumProvider), isTrue);
    });

    test(
      'clearCache drops entitlement so the next user does not inherit it',
      () async {
        final c = containerWith(
          () async =>
              const DfSubscriptionStatus(status: 'active', isPremium: true),
        );
        await c.read(dfSubscriptionProvider.future);
        await c.read(dfSubscriptionProvider.notifier).clearCache();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('df_billing_last_status_v1'), isNull);
      },
    );

    test('the debug override wins over the backend', () async {
      final c = containerWith(() async => const DfSubscriptionStatus.free());
      await c.read(dfSubscriptionProvider.future);
      expect(c.read(dfIsPremiumProvider), isFalse);

      c.read(dfDebugPremiumOverrideProvider.notifier).set(true);
      expect(c.read(dfIsPremiumProvider), isTrue);
    });
  });
}

bool _alwaysTrue() => true;
