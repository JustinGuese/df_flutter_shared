import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// One spotlight within a coach-mark sequence: which widget, what to say
/// about it, and where the bubble sits.
///
/// A single [TourStep] can spotlight several widgets in sequence on one
/// screen (e.g. legend, then stats, then controls) — each becomes one
/// [TourTarget] passed together to `showTourCoachMarks`.
@immutable
class TourTarget {
  const TourTarget({
    required this.key,
    required this.title,
    required this.body,
    this.align = ContentAlign.bottom,
    this.circle = false,
  });

  /// The widget to spotlight.
  final GlobalKey key;

  /// Bubble heading.
  final String title;

  /// The "why" — what this widget does and why it matters, not just what it's
  /// called.
  final String body;

  /// Where the bubble sits relative to the spotlighted widget. Use [top] for
  /// targets near the bottom of the screen (e.g. a bottom nav bar) so the
  /// bubble doesn't run off-screen.
  final ContentAlign align;

  /// Round spotlight instead of a rounded rectangle — for icon buttons.
  final bool circle;
}
