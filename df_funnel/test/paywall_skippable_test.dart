import 'package:df_funnel/df_funnel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, DfFunnelConfig)> setup({
    required bool skippable,
  }) async {
    SharedPreferences.setMockInitialValues({
      'df_funnel_onboarding_completed': true,
    });
    final config = DfFunnelConfig(paywallSkippable: skippable);
    final container = ProviderContainer(
      overrides: [
        dfFunnelSharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(dfFunnelProvider(config).notifier).init();
    return (container, config);
  }

  test('defaults to skippable', () {
    expect(const DfFunnelConfig().paywallSkippable, isTrue);
    expect(
      const DfFunnelConfig().copyWith(paywallSkippable: false).paywallSkippable,
      isFalse,
    );
  });

  test('skipping the paywall advances when skippable', () async {
    final (c, cfg) = await setup(skippable: true);
    expect(c.read(dfFunnelProvider(cfg)).currentStep, DfFunnelStep.paywall);
    await c.read(dfFunnelProvider(cfg).notifier).skipStep(DfFunnelStep.paywall);
    expect(c.read(dfFunnelProvider(cfg)).paywallCompleted, isTrue);
  });

  test('skipping the paywall is ignored when not skippable', () async {
    final (c, cfg) = await setup(skippable: false);
    final n = c.read(dfFunnelProvider(cfg).notifier);
    await n.skipStep(DfFunnelStep.paywall);
    await n.completePaywall(skipped: true);
    expect(c.read(dfFunnelProvider(cfg)).currentStep, DfFunnelStep.paywall);
    await n.completePaywall(); // real completion still works
    expect(c.read(dfFunnelProvider(cfg)).paywallCompleted, isTrue);
  });
}
