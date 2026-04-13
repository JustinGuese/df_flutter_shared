import 'package:flutter/material.dart';
import 'learning_step_model.dart';

/// Configuration for a single learning course.
///
/// This model is fully generic — it has no NaviCare-specific imports.
/// All NaviCare-specific content (e.g. risk module names, German text) is
/// injected by the consuming app via [LearningCourseContent] maps.
@immutable
class LearningCourseModel {
  const LearningCourseModel({
    required this.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.steps,
    required this.riskLevelLabel,
    required this.riskLevelColor,
    this.daysSinceLastAccess,
  });

  /// Stable identifier used as SharedPreferences key prefix and route param.
  final String key;

  final String emoji;
  final String title;

  /// One-line description shown on overview cards.
  final String subtitle;

  /// Two-colour gradient for the course header.
  final List<Color> gradient;

  /// Always 4 steps in order: sofortUmsetzbar, beiRisiko, warnsignale, notfall.
  final List<LearningStepModel> steps;

  /// Human-readable risk level label, e.g. "Hohes Risiko".
  final String riskLevelLabel;

  /// Semantic colour for the risk badge: green / amber / red.
  final Color riskLevelColor;

  /// Days since the user last opened this course.
  /// Injected by the provider layer from the backend [LearningProgress.last_accessed].
  /// Null = never opened.
  final int? daysSinceLastAccess;

  LearningCourseModel copyWith({
    int? daysSinceLastAccess,
    String? riskLevelLabel,
    Color? riskLevelColor,
    List<LearningStepModel>? steps,
  }) {
    return LearningCourseModel(
      key: key,
      emoji: emoji,
      title: title,
      subtitle: subtitle,
      gradient: gradient,
      steps: steps ?? this.steps,
      riskLevelLabel: riskLevelLabel ?? this.riskLevelLabel,
      riskLevelColor: riskLevelColor ?? this.riskLevelColor,
      daysSinceLastAccess: daysSinceLastAccess ?? this.daysSinceLastAccess,
    );
  }
}
