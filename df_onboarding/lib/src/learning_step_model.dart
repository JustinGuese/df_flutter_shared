import 'package:flutter/material.dart';

/// The type of a section within a learning course.
enum CourseSectionType {
  sofortUmsetzbar,
  beiRisiko,
  warnsignale,
  notfall,
}

/// A single section within a [LearningCourseModel].
///
/// [type] determines layout (interactive vs. read-only).
/// [items] are the bullet points shown inside the section.
/// [ctaLabel] / [onCta] are used exclusively on the [notfall] section.
@immutable
class LearningStepModel {
  const LearningStepModel({
    required this.type,
    required this.title,
    required this.emoji,
    required this.items,
    this.ctaLabel,
    this.onCta,
  });

  final CourseSectionType type;
  final String title;
  final String emoji;

  /// Bullet-point content for this section.
  final List<String> items;

  /// Optional call-to-action label (used on [CourseSectionType.notfall]).
  final String? ctaLabel;

  /// Callback when the CTA button is tapped.
  final VoidCallback? onCta;
}
