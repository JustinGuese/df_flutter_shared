import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePresenter implements DfPaywallPresenter {
  _FakePresenter({
    this.paywallResult = DfPaywallResult.cancelled,
    this.exitOfferResult = DfPaywallResult.purchased,
  });

  DfPaywallResult paywallResult;
  DfPaywallResult exitOfferResult;
  int paywallCalls = 0;
  int exitOfferCalls = 0;

  @override
  Future<DfPaywallResult> presentPaywall({
    String? placement,
    bool force = false,
  }) async {
    paywallCalls++;
    return paywallResult;
  }

  @override
  Future<DfPaywallResult> presentExitOffer() async {
    exitOfferCalls++;
    return exitOfferResult;
  }

  @override
  Future<void> presentCustomerCenter() async {}
}

void main() {
  setUp(() {
    RecordingAnalyticsSink.install();
    SharedPreferences.setMockInitialValues({});
    DfRevenueCat.debugReset();
    DfRevenueCat.configure(
      const DfRevenueCatConfig(
        iosApiKey: 'test_ios',
        androidApiKey: 'test_android',
        entitlementId: 'pro',
        exitOfferPlacement: 'exit_offer',
        exitOfferAfter: {'onboarding', 'feed_sheet'},
        exitOfferShownKey: 'exit_offer_shown',
      ),
    );
  });

  tearDown(() {
    DfAnalyticsCore.debugReset();
    DfRevenueCat.debugReset();
  });

  group('DfRevenueCat.presentExitOffer once-only', () {
    test(
      'presents on first call and records flag in SharedPreferences',
      () async {
        final presenter = _FakePresenter(
          exitOfferResult: DfPaywallResult.purchased,
        );
        DfRevenueCat.presenter = presenter;

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('exit_offer_shown'), isNull);

        final result = await DfRevenueCat.presentExitOffer(prefs: prefs);

        expect(result, DfPaywallResult.purchased);
        expect(presenter.exitOfferCalls, 1);
        expect(prefs.getBool('exit_offer_shown'), isTrue);

        // Second call should return notPresented and not call presenter
        final secondResult = await DfRevenueCat.presentExitOffer(prefs: prefs);
        expect(secondResult, DfPaywallResult.notPresented);
        expect(presenter.exitOfferCalls, 1);
      },
    );

    test('does not record flag if exit offer returns notPresented', () async {
      final presenter = _FakePresenter(
        exitOfferResult: DfPaywallResult.notPresented,
      );
      DfRevenueCat.presenter = presenter;

      final prefs = await SharedPreferences.getInstance();
      final result = await DfRevenueCat.presentExitOffer(prefs: prefs);

      expect(result, DfPaywallResult.notPresented);
      expect(presenter.exitOfferCalls, 1);
      expect(prefs.getBool('exit_offer_shown'), isNull);
    });
  });

  group('DfPaywallLauncher exit offer placement filter', () {
    testWidgets('triggers exit offer when placement is in exitOfferAfter', (
      tester,
    ) async {
      final presenter = _FakePresenter(
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

      final prefs = await SharedPreferences.getInstance();
      final result = await DfPaywallLauncher.show(
        buildContext,
        placement: 'onboarding',
        presenter: presenter,
        prefs: prefs,
      );

      expect(presenter.paywallCalls, 1);
      expect(presenter.exitOfferCalls, 1);
      expect(result, DfPaywallResult.purchased);
      expect(prefs.getBool('exit_offer_shown'), isTrue);
    });

    testWidgets(
      'does not trigger exit offer when placement is not in exitOfferAfter',
      (tester) async {
        final presenter = _FakePresenter(
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

        final prefs = await SharedPreferences.getInstance();
        final result = await DfPaywallLauncher.show(
          buildContext,
          placement: 'other_screen',
          presenter: presenter,
          prefs: prefs,
        );

        expect(presenter.paywallCalls, 1);
        expect(presenter.exitOfferCalls, 0);
        expect(result, DfPaywallResult.cancelled);
        expect(prefs.getBool('exit_offer_shown'), isNull);
      },
    );

    testWidgets(
      'only shows exit offer once across multiple cancelled paywalls',
      (tester) async {
        final presenter = _FakePresenter(
          paywallResult: DfPaywallResult.cancelled,
          exitOfferResult: DfPaywallResult.cancelled,
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

        final prefs = await SharedPreferences.getInstance();

        // First presentation from onboarding (in exitOfferAfter)
        final res1 = await DfPaywallLauncher.show(
          buildContext,
          placement: 'onboarding',
          presenter: presenter,
          prefs: prefs,
        );
        expect(presenter.paywallCalls, 1);
        expect(presenter.exitOfferCalls, 1);
        expect(res1, DfPaywallResult.cancelled);
        expect(prefs.getBool('exit_offer_shown'), isTrue);

        // Second presentation from feed_sheet (also in exitOfferAfter)
        final res2 = await DfPaywallLauncher.show(
          buildContext,
          placement: 'feed_sheet',
          presenter: presenter,
          prefs: prefs,
        );
        expect(presenter.paywallCalls, 2);
        expect(presenter.exitOfferCalls, 1); // Not called again!
        expect(res2, DfPaywallResult.cancelled);
      },
    );
  });
}
