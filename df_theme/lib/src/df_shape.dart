import 'package:flutter/widgets.dart';

/// Corner radii.
///
/// Radius is one of the loudest identity signals a design system carries, so
/// the set is deliberately small. The house values are slightly off the
/// Material defaults — 14 rather than 12 or 16 for the workhorse card — which
/// is enough to read as a decision rather than a framework leftover.
@immutable
class DfShape {
  const DfShape({
    this.sm = 10,
    this.md = 14,
    this.lg = 20,
    this.xl = 28,
    this.pill = 999,
  });

  /// Square-ish, for apps whose identity rejects rounding (pixel-art, terminal).
  const DfShape.sharp() : sm = 0, md = 0, lg = 0, xl = 0, pill = 0;

  /// Chips, badges, small inputs.
  final double sm;

  /// The workhorse: cards, buttons, text fields.
  final double md;

  /// Bottom sheets, dialogs, large panels.
  final double lg;

  /// Hero surfaces and full-bleed feature cards.
  final double xl;

  /// Fully rounded ends.
  final double pill;

  BorderRadius get radiusSm => BorderRadius.circular(sm);
  BorderRadius get radiusMd => BorderRadius.circular(md);
  BorderRadius get radiusLg => BorderRadius.circular(lg);
  BorderRadius get radiusXl => BorderRadius.circular(xl);
  BorderRadius get radiusPill => BorderRadius.circular(pill);

  /// Top-only rounding, for bottom sheets.
  BorderRadius get radiusSheet =>
      BorderRadius.vertical(top: Radius.circular(lg));

  DfShape copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? pill,
  }) => DfShape(
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
    pill: pill ?? this.pill,
  );

  static DfShape lerp(DfShape a, DfShape b, double t) => DfShape(
    sm: a.sm + (b.sm - a.sm) * t,
    md: a.md + (b.md - a.md) * t,
    lg: a.lg + (b.lg - a.lg) * t,
    xl: a.xl + (b.xl - a.xl) * t,
    pill: a.pill + (b.pill - a.pill) * t,
  );
}
