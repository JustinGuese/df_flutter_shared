import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:df_onboarding/df_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RecordingAnalyticsSink analytics;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    analytics = RecordingAnalyticsSink.install();
  });
  tearDown(DfAnalyticsCore.debugReset);

  OnboardingPageModel page(String title) => OnboardingPageModel(
    icon: Icons.star,
    title: title,
    subtitle: 'subtitle',
    features: const [],
    gradient: const [Colors.indigo, Colors.teal],
    emoji: '*',
  );

  Future<void> pumpOnboarding(
    WidgetTester tester, {
    bool isHelpMode = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingConfigProvider.overrideWithValue(
            OnboardingConfig(pages: [page('One'), page('Two'), page('Three')]),
          ),
        ],
        child: MaterialApp(home: OnboardingScreen(isHelpMode: isHelpMode)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Map<String, Object> paramsOf(String name) =>
      analytics.named(name).single.parameters;

  testWidgets('reports the start and every page shown', (tester) async {
    await pumpOnboarding(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(analytics.names, [
      DfEvents.tutorialBegin,
      DfEvents.onboardingPageView,
      DfEvents.onboardingPageView,
    ]);
    expect(analytics.named(DfEvents.onboardingPageView).last.parameters, {
      DfEventParams.pageIndex: 2,
      DfEventParams.pageCount: 3,
    });
  });

  testWidgets('Skip is reported as skipped, with the page it left on', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(paramsOf(DfEvents.tutorialComplete), {
      DfEventParams.skipped: 1,
      DfEventParams.pageIndex: 2,
    });
  });

  testWidgets('finishing the last page is not skipped, and counts once', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(paramsOf(DfEvents.tutorialComplete), {
      DfEventParams.skipped: 0,
      DfEventParams.pageIndex: 3,
    });
  });

  testWidgets('help mode reports nothing', (tester) async {
    await pumpOnboarding(tester, isHelpMode: true);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(analytics.events, isEmpty);
  });
}
