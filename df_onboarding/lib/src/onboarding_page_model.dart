import 'package:flutter/material.dart';

/// Model for a single onboarding page (icon, title, subtitle, features, gradient, emoji).
@immutable
class OnboardingPageModel {
  const OnboardingPageModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.gradient,
    required this.emoji,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> features;
  final List<Color> gradient;
  final String emoji;
}
