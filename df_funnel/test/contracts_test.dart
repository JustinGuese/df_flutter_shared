import '../../df_analytics_core/lib/df_analytics_core.dart';
import 'package:df_funnel/df_funnel.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfEvents paywall constants', () {
    test('constants preserve exact analytics strings for dashboards', () {
      expect(DfEvents.paywallOpened, equals('paywall_opened'));
      expect(DfEvents.paywallResult, equals('paywall_result'));
    });
  });

  group('Funnel enums', () {
    test('DfFunnelStep contains expected order of steps', () {
      expect(
        DfFunnelStep.values,
        equals([
          DfFunnelStep.onboarding,
          DfFunnelStep.paywall,
          DfFunnelStep.login,
        ]),
      );
    });

    test('DfLoginMode contains expected modes', () {
      expect(
        DfLoginMode.values,
        equals([
          DfLoginMode.required,
          DfLoginMode.optional,
          DfLoginMode.deferred,
        ]),
      );
    });
  });

  group('DfFunnelConfig', () {
    test('provides sensible defaults', () {
      const config = DfFunnelConfig();

      expect(
        config.steps,
        equals([
          DfFunnelStep.onboarding,
          DfFunnelStep.paywall,
          DfFunnelStep.login,
        ]),
      );
      expect(config.loginMode, equals(DfLoginMode.deferred));
      expect(config.paywallPlacement, equals('onboarding'));
      expect(config.paywallPresenter, isNull);
      expect(config.entitlementReader, isNull);
      expect(
        config.onboardingCompletedKey,
        equals('df_funnel_onboarding_completed'),
      );
      expect(
        config.paywallCompletedKey,
        equals('df_funnel_paywall_completed'),
      );
      expect(config.loginCompletedKey, equals('df_funnel_login_completed'));
    });

    test('copyWith updates specified fields', () {
      const base = DfFunnelConfig();
      final updated = base.copyWith(
        loginMode: DfLoginMode.required,
        paywallPlacement: 'custom_placement',
        steps: [DfFunnelStep.login],
      );

      expect(updated.loginMode, equals(DfLoginMode.required));
      expect(updated.paywallPlacement, equals('custom_placement'));
      expect(updated.steps, equals([DfFunnelStep.login]));
      expect(
        updated.onboardingCompletedKey,
        equals(base.onboardingCompletedKey),
      );
    });

    test('equality and hashCode adhere to value equality', () {
      const config1 = DfFunnelConfig();
      const config2 = DfFunnelConfig();
      final config3 = config1.copyWith(loginMode: DfLoginMode.optional);

      expect(config1, equals(config2));
      expect(config1.hashCode, equals(config2.hashCode));
      expect(config1, isNot(equals(config3)));
    });

    test('callback seams match expected signatures', () {
      bool entitlementChecked = false;

      final DfEntitlementReader reader = () {
        entitlementChecked = true;
        return true;
      };

      final config = DfFunnelConfig(
        entitlementReader: reader,
      );

      expect(config.entitlementReader!(), isTrue);
      expect(entitlementChecked, isTrue);
    });

    testWidgets('paywallPresenter callback can be invoked', (tester) async {
      bool paywallPresented = false;
      String? recordedPlacement;

      final DfPaywallPresenter presenter = (
        BuildContext context, {
        String? placement,
      }) async {
        paywallPresented = true;
        recordedPlacement = placement;
        return DfPaywallResult.purchased;
      };

      final config = DfFunnelConfig(paywallPresenter: presenter);

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            return Container();
          },
        ),
      );
      final element = tester.element(find.byType(Container));
      final result = await config.paywallPresenter!(
        element,
        placement: 'test_placement',
      );

      expect(result, equals(DfPaywallResult.purchased));
      expect(paywallPresented, isTrue);
      expect(recordedPlacement, equals('test_placement'));
    });
  });
}
