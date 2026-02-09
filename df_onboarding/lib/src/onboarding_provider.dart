import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_config.dart';

final onboardingConfigProvider = Provider<OnboardingConfig>((ref) {
  throw UnsupportedError(
    'onboardingConfigProvider must be overridden in ProviderScope.overrides',
  );
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final config = ref.watch(onboardingConfigProvider);
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(config.preferencesKey) ?? false;
});
