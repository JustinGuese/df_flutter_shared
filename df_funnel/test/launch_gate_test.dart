import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:df_funnel/src/contracts.dart';
import 'package:df_funnel/src/funnel_state.dart';
import 'package:df_funnel/src/launch_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RecordingAnalyticsSink analytics;

  setUp(() {
    analytics = RecordingAnalyticsSink.install();
  });

  tearDown(() {
    DfAnalyticsCore.debugReset();
  });

  Widget buildGate({
    required DfFunnelConfig config,
    WidgetBuilder? homeBuilder,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: DfLaunchGate(
          config: config,
          homeBuilder: homeBuilder ?? (_) => const Text('HOME_SCREEN'),
        ),
      ),
    );
  }

  group('DfLaunchGate', () {
    testWidgets('fresh-install runs onboarding, paywall, login, then home',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final config = DfFunnelConfig(
        loginMode: DfLoginMode.optional,
        paywallPresenter: (context, {placement}) async =>
            DfPaywallResult.purchased,
      );

      await tester.pumpWidget(buildGate(config: config));

      // 1. Spinner while loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // 2. Onboarding step is shown and emits tutorialBegin
      expect(find.byKey(const Key('df_funnel_onboarding_step')), findsOneWidget);
      expect(analytics.names, contains(DfEvents.tutorialBegin));
      expect(analytics.names, isNot(contains(DfEvents.tutorialComplete)));

      // Complete onboarding
      await tester.tap(find.byKey(const Key('df_funnel_onboarding_complete_button')));
      await tester.pumpAndSettle();

      // Emitted tutorialComplete and moved to paywall step
      expect(analytics.names, contains(DfEvents.tutorialComplete));
      expect(find.byKey(const Key('df_funnel_paywall_step')), findsOneWidget);

      // Complete paywall step
      await tester.tap(find.byKey(const Key('df_funnel_paywall_continue_button')));
      await tester.pumpAndSettle();

      // 3. Login step is shown with skip option
      expect(find.byKey(const Key('df_funnel_login_step')), findsOneWidget);
      expect(find.byKey(const Key('df_funnel_login_skip_button')), findsOneWidget);

      // Complete login step
      await tester.tap(find.byKey(const Key('df_funnel_login_submit_button')));
      await tester.pumpAndSettle();

      // 4. Funnel completed, home screen displayed
      expect(find.text('HOME_SCREEN'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(config.onboardingCompletedKey), isTrue);
      expect(prefs.getBool(config.paywallCompletedKey), isTrue);
      expect(prefs.getBool(config.loginCompletedKey), isTrue);
    });

    testWidgets('skips paywall if user is already pro', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final config = DfFunnelConfig(
        entitlementReader: () => true,
        loginMode: DfLoginMode.deferred,
      );

      await tester.pumpWidget(buildGate(config: config));
      await tester.pumpAndSettle();

      // Starts at onboarding
      expect(find.byKey(const Key('df_funnel_onboarding_step')), findsOneWidget);

      // Complete onboarding
      await tester.tap(find.byKey(const Key('df_funnel_onboarding_complete_button')));
      await tester.pumpAndSettle();

      // Paywall should be completely skipped, going straight home
      expect(find.byKey(const Key('df_funnel_paywall_step')), findsNothing);
      expect(find.text('HOME_SCREEN'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(config.paywallCompletedKey), isTrue);
    });

    testWidgets('paywall skip path advances to next step', (tester) async {
      SharedPreferences.setMockInitialValues({});
      const config = DfFunnelConfig(
        entitlementReader: null,
        loginMode: DfLoginMode.deferred,
      );

      await tester.pumpWidget(buildGate(config: config));
      await tester.pumpAndSettle();

      // Finish onboarding
      await tester.tap(find.byKey(const Key('df_funnel_onboarding_complete_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('df_funnel_paywall_step')), findsOneWidget);

      // Skip paywall
      await tester.tap(find.byKey(const Key('df_funnel_paywall_skip_button')));
      await tester.pumpAndSettle();

      // Lands on home
      expect(find.text('HOME_SCREEN'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(config.paywallCompletedKey), isTrue);
    });

    group('login modes', () {
      testWidgets('deferred mode skips login step', (tester) async {
        const config = DfFunnelConfig(loginMode: DfLoginMode.deferred);
        SharedPreferences.setMockInitialValues({
          config.onboardingCompletedKey: true,
          config.paywallCompletedKey: true,
        });

        await tester.pumpWidget(buildGate(config: config));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('df_funnel_login_step')), findsNothing);
        expect(find.text('HOME_SCREEN'), findsOneWidget);
      });

      testWidgets('optional mode shows skippable screen and allows skip',
          (tester) async {
        const config = DfFunnelConfig(loginMode: DfLoginMode.optional);
        SharedPreferences.setMockInitialValues({
          config.onboardingCompletedKey: true,
          config.paywallCompletedKey: true,
        });

        await tester.pumpWidget(buildGate(config: config));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('df_funnel_login_step')), findsOneWidget);
        expect(
          find.byKey(const Key('df_funnel_login_skip_button')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('df_funnel_login_skip_button')));
        await tester.pumpAndSettle();

        expect(find.text('HOME_SCREEN'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(config.loginCompletedKey), isTrue);
      });

      testWidgets('required mode blocks progression until completed',
          (tester) async {
        const config = DfFunnelConfig(loginMode: DfLoginMode.required);
        SharedPreferences.setMockInitialValues({
          config.onboardingCompletedKey: true,
          config.paywallCompletedKey: true,
        });

        await tester.pumpWidget(buildGate(config: config));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('df_funnel_login_step')), findsOneWidget);
        expect(find.byKey(const Key('df_funnel_login_skip_button')), findsNothing);

        // Sign in to unblock
        await tester.tap(find.byKey(const Key('df_funnel_login_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('HOME_SCREEN'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(config.loginCompletedKey), isTrue);
      });
    });

    group('resume after partial flow', () {
      testWidgets('resumes from paywall when onboarding is already done',
          (tester) async {
        const config = DfFunnelConfig(loginMode: DfLoginMode.deferred);
        SharedPreferences.setMockInitialValues({
          config.onboardingCompletedKey: true,
        });

        await tester.pumpWidget(buildGate(config: config));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('df_funnel_onboarding_step')), findsNothing);
        expect(find.byKey(const Key('df_funnel_paywall_step')), findsOneWidget);
      });

      testWidgets('resumes from login when onboarding and paywall are done',
          (tester) async {
        const config = DfFunnelConfig(loginMode: DfLoginMode.required);
        SharedPreferences.setMockInitialValues({
          config.onboardingCompletedKey: true,
          config.paywallCompletedKey: true,
        });

        await tester.pumpWidget(buildGate(config: config));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('df_funnel_onboarding_step')), findsNothing);
        expect(find.byKey(const Key('df_funnel_paywall_step')), findsNothing);
        expect(find.byKey(const Key('df_funnel_login_step')), findsOneWidget);
      });

      testWidgets('resumes straight home when all steps are already done',
          (tester) async {
        const config = DfFunnelConfig(loginMode: DfLoginMode.required);
        SharedPreferences.setMockInitialValues({
          config.onboardingCompletedKey: true,
          config.paywallCompletedKey: true,
          config.loginCompletedKey: true,
        });

        await tester.pumpWidget(buildGate(config: config));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('df_funnel_onboarding_step')), findsNothing);
        expect(find.byKey(const Key('df_funnel_paywall_step')), findsNothing);
        expect(find.byKey(const Key('df_funnel_login_step')), findsNothing);
        expect(find.text('HOME_SCREEN'), findsOneWidget);
      });
    });
  });
}
