import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockPresenter implements DfPaywallPresenter {
  _MockPresenter({
    this.paywallResult = DfPaywallResult.purchased,
    this.exitOfferResult = DfPaywallResult.purchased,
    this.throwOnPaywall = false,
  });

  DfPaywallResult paywallResult;
  DfPaywallResult exitOfferResult;
  bool throwOnPaywall;

  @override
  Future<DfPaywallResult> presentPaywall({
    String? placement,
    bool force = false,
  }) async {
    if (throwOnPaywall) {
      throw Exception('SDK failure');
    }
    return paywallResult;
  }

  @override
  Future<DfPaywallResult> presentExitOffer() async => exitOfferResult;

  @override
  Future<void> presentCustomerCenter() async {}
}

void main() {
  late RecordingAnalyticsSink analytics;

  setUp(() {
    analytics = RecordingAnalyticsSink.install();
    SharedPreferences.setMockInitialValues({});
    DfRevenueCat.debugReset();
    DfRevenueCat.configure(
      const DfRevenueCatConfig(
        iosApiKey: 'test_ios',
        androidApiKey: 'test_android',
        entitlementId: 'test_pro',
        exitOfferPlacement: 'exit_offer',
        exitOfferAfter: {'paywall_card'},
        exitOfferShownKey: 'exit_offer_shown',
      ),
    );
  });

  tearDown(() {
    DfAnalyticsCore.debugReset();
    DfRevenueCat.debugReset();
  });

  group('DfPaywallLauncher tracking events', () {
    testWidgets('tracks opened and purchased result and invokes onPurchased', (
      tester,
    ) async {
      final presenter = _MockPresenter(
        paywallResult: DfPaywallResult.purchased,
      );

      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildContext = context;
              return const Placeholder();
            },
          ),
        ),
      );

      var purchasedHookCalled = false;
      final result = await DfPaywallLauncher.show(
        buildContext,
        placement: 'header_button',
        presenter: presenter,
        onPurchased: (context) {
          purchasedHookCalled = true;
        },
      );

      expect(result, DfPaywallResult.purchased);
      expect(purchasedHookCalled, isTrue);

      expect(analytics.names, ['paywall_opened', 'paywall_result']);
      final opened = analytics.named('paywall_opened').single;
      expect(opened.parameters, {'placement': 'header_button'});

      final resEvent = analytics.named('paywall_result').single;
      expect(resEvent.parameters, {
        'placement': 'header_button',
        'result': 'purchased',
      });
    });

    testWidgets('tracks opened and restored result and invokes onPurchased', (
      tester,
    ) async {
      final presenter = _MockPresenter(paywallResult: DfPaywallResult.restored);

      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildContext = context;
              return const Placeholder();
            },
          ),
        ),
      );

      var purchasedHookCalled = false;
      final result = await DfPaywallLauncher.show(
        buildContext,
        placement: 'settings_restore',
        presenter: presenter,
        onPurchased: (context) {
          purchasedHookCalled = true;
        },
      );

      expect(result, DfPaywallResult.restored);
      expect(purchasedHookCalled, isTrue);

      expect(analytics.names, ['paywall_opened', 'paywall_result']);
      expect(analytics.events[1].parameters, {
        'placement': 'settings_restore',
        'result': 'restored',
      });
    });

    testWidgets('tracks exit offer event when main paywall is cancelled', (
      tester,
    ) async {
      final presenter = _MockPresenter(
        paywallResult: DfPaywallResult.cancelled,
        exitOfferResult: DfPaywallResult.purchased,
      );

      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildContext = context;
              return const Placeholder();
            },
          ),
        ),
      );

      var hookCalled = false;
      final result = await DfPaywallLauncher.show(
        buildContext,
        placement: 'paywall_card',
        presenter: presenter,
        onPurchased: (context) {
          hookCalled = true;
        },
      );

      expect(result, DfPaywallResult.purchased);
      expect(hookCalled, isTrue);

      // Expect: paywall_opened, paywall_result (cancelled), paywall_result (exit offer purchased)
      expect(analytics.names, [
        'paywall_opened',
        'paywall_result',
        'paywall_result',
      ]);

      expect(analytics.events[0].parameters, {'placement': 'paywall_card'});
      expect(analytics.events[1].parameters, {
        'placement': 'paywall_card',
        'result': 'cancelled',
      });
      expect(analytics.events[2].parameters, {
        'placement': 'exit_offer',
        'result': 'purchased',
      });
    });

    testWidgets('tracks error event when presenter throws exception', (
      tester,
    ) async {
      final presenter = _MockPresenter(throwOnPaywall: true);

      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildContext = context;
              return const Placeholder();
            },
          ),
        ),
      );

      final result = await DfPaywallLauncher.show(
        buildContext,
        placement: 'broken_placement',
        presenter: presenter,
      );

      expect(result, DfPaywallResult.error);
      expect(analytics.names, ['paywall_opened', 'paywall_result']);
      expect(analytics.events[1].parameters, {
        'placement': 'broken_placement',
        'result': 'error',
      });
    });
  });
}
