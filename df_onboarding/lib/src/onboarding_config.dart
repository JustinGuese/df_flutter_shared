import 'package:flutter/foundation.dart';

import 'onboarding_page_model.dart';

@immutable
class OnboardingConfig {
  const OnboardingConfig({
    required this.pages,
    this.preferencesKey = 'onboarding_completed',
    this.showSkipButton = true,
  });

  final List<OnboardingPageModel> pages;
  final String preferencesKey;
  final bool showSkipButton;
}
