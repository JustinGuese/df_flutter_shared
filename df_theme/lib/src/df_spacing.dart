import 'package:flutter/widgets.dart';

/// The spacing scale, on a 4dp grid.
///
/// Nine steps is more than a scale strictly needs, but it matches what the
/// apps already use so nothing has to be re-measured during migration.
/// In new code reach for [md], [lg] and [xl] first — the others exist for
/// fine-tuning, not as equal choices.
@immutable
class DfSpacing {
  const DfSpacing({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.mdPlus = 20,
    this.lg = 24,
    this.xl = 32,
    this.xlPlus = 40,
    this.xxl = 48,
  });

  /// A denser variant, for information-heavy screens.
  const DfSpacing.compact()
    : xxs = 2,
      xs = 6,
      sm = 10,
      md = 12,
      mdPlus = 16,
      lg = 20,
      xl = 24,
      xlPlus = 32,
      xxl = 40;

  final double xxs;
  final double xs;
  final double sm;

  /// The default gap between related elements.
  final double md;
  final double mdPlus;

  /// The default gap between groups.
  final double lg;

  /// The default gap between sections.
  final double xl;
  final double xlPlus;
  final double xxl;

  /// Horizontal page margin. Screens should use this rather than picking a
  /// number, so every DF screen shares one measure.
  double get pageMargin => md;

  DfSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? mdPlus,
    double? lg,
    double? xl,
    double? xlPlus,
    double? xxl,
  }) => DfSpacing(
    xxs: xxs ?? this.xxs,
    xs: xs ?? this.xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    mdPlus: mdPlus ?? this.mdPlus,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
    xlPlus: xlPlus ?? this.xlPlus,
    xxl: xxl ?? this.xxl,
  );

  static DfSpacing lerp(DfSpacing a, DfSpacing b, double t) => DfSpacing(
    xxs: _l(a.xxs, b.xxs, t),
    xs: _l(a.xs, b.xs, t),
    sm: _l(a.sm, b.sm, t),
    md: _l(a.md, b.md, t),
    mdPlus: _l(a.mdPlus, b.mdPlus, t),
    lg: _l(a.lg, b.lg, t),
    xl: _l(a.xl, b.xl, t),
    xlPlus: _l(a.xlPlus, b.xlPlus, t),
    xxl: _l(a.xxl, b.xxl, t),
  );

  static double _l(double a, double b, double t) => a + (b - a) * t;
}
