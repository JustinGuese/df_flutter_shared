import 'package:flutter/material.dart';

import 'df_motion.dart';
import 'df_palette.dart';
import 'df_shape.dart';
import 'df_spacing.dart';
import 'df_typography.dart';

/// The DF tokens, carried on `ThemeData.extensions`.
///
/// Material's [ColorScheme] cannot express most of what DF widgets need — the
/// canvas/surface split, a third text level, semantic colours in four weights,
/// spacing, radii, motion. Those live here.
///
/// Read them with the [DfThemeContext] extension:
///
/// ```dart
/// Container(
///   padding: EdgeInsets.all(context.df.spacing.md),
///   decoration: BoxDecoration(
///     color: context.df.colors.surface,
///     borderRadius: context.df.shape.radiusMd,
///   ),
/// )
/// ```
@immutable
class DfTokens extends ThemeExtension<DfTokens> {
  const DfTokens({
    required this.brandName,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.shape,
    required this.motion,
    this.logoAsset,
  });

  final String brandName;
  final DfPalette colors;
  final DfTypography typography;
  final DfSpacing spacing;
  final DfShape shape;
  final DfMotion motion;
  final String? logoAsset;

  // --- Shorthands the widgets actually reach for -----------------------------

  bool get isDark => colors.isDark;

  /// Hairline border for cards and containers.
  Border get hairlineBorder => Border.all(color: colors.hairline, width: 1);

  /// The house card shadow: low opacity and tinted with the brand rather than
  /// black, so it reads as depth rather than dirt.
  List<BoxShadow> get cardShadow => <BoxShadow>[
    BoxShadow(
      color: colors.brand.base.withValues(alpha: isDark ? 0.28 : 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// A stronger version for raised surfaces — sheets, menus, dialogs.
  List<BoxShadow> get elevatedShadow => <BoxShadow>[
    BoxShadow(
      color: colors.brand.base.withValues(alpha: isDark ? 0.36 : 0.10),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  /// Monospaced tabular figures, in three sizes.
  TextStyle get dataLarge => typography.data(20, colors.textPrimary);
  TextStyle get dataMedium => typography.data(16, colors.textPrimary);
  TextStyle get dataSmall => typography.data(13, colors.textSecondary);

  /// The eyebrow of the DF section header — small, uppercase, tracked.
  TextStyle get eyebrow => typography.eyebrow(colors.accent.base);

  /// A named gradient.
  ///
  /// Falls back to the *deep* brand and accent weights rather than `base`,
  /// because a gradient panel is almost always painted under light text. With
  /// `base`, a light brand (SocialAnxify's gold + mint) produced a pale panel
  /// with unreadable white copy on it.
  LinearGradient gradient(
    String name, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(begin: begin, end: end, colors: gradientStops(name));
  }

  List<Color> gradientStops(String name) =>
      colors.gradient(name) ?? <Color>[colors.brand.deep, colors.accent.deep];

  /// The foreground colour to use on top of [gradient].
  ///
  /// Measures the gradient's lightest stop instead of assuming white, so a
  /// brand with pale gradient stops still gets readable copy.
  Color onGradient(String name) {
    final lightest = gradientStops(
      name,
    ).reduce((a, b) => a.computeLuminance() >= b.computeLuminance() ? a : b);
    // 0.5 on the lightest stop: if even the brightest end stays mid-dark,
    // white wins everywhere along the ramp.
    return lightest.computeLuminance() > 0.5
        ? colors.textPrimary
        : Colors.white;
  }

  @override
  DfTokens copyWith({
    String? brandName,
    DfPalette? colors,
    DfTypography? typography,
    DfSpacing? spacing,
    DfShape? shape,
    DfMotion? motion,
    String? logoAsset,
  }) => DfTokens(
    brandName: brandName ?? this.brandName,
    colors: colors ?? this.colors,
    typography: typography ?? this.typography,
    spacing: spacing ?? this.spacing,
    shape: shape ?? this.shape,
    motion: motion ?? this.motion,
    logoAsset: logoAsset ?? this.logoAsset,
  );

  @override
  DfTokens lerp(covariant DfTokens? other, double t) {
    if (other == null) return this;
    return DfTokens(
      brandName: t < 0.5 ? brandName : other.brandName,
      colors: DfPalette.lerp(colors, other.colors, t),
      typography: DfTypography.lerp(typography, other.typography, t),
      spacing: DfSpacing.lerp(spacing, other.spacing, t),
      shape: DfShape.lerp(shape, other.shape, t),
      motion: DfMotion.lerp(motion, other.motion, t),
      logoAsset: t < 0.5 ? logoAsset : other.logoAsset,
    );
  }
}

/// `context.df` — the way every DF widget reads tokens.
extension DfThemeContext on BuildContext {
  /// The DF tokens for this subtree.
  ///
  /// Throws a [FlutterError] with a fix-it message if the app forgot to build
  /// its theme with `DfTheme.light` / `DfTheme.dark`, which is far easier to
  /// act on than a null dereference deep inside a shared widget.
  DfTokens get df {
    final tokens = Theme.of(this).extension<DfTokens>();
    if (tokens == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No DfTokens found in the current Theme.'),
        ErrorDescription(
          'A df_* widget tried to read design tokens, but the enclosing '
          'ThemeData has no DfTokens extension.',
        ),
        ErrorHint(
          'Build the app theme with DfTheme.light(brand) / DfTheme.dark(brand) '
          'from package:df_theme, or add DfTokens to ThemeData.extensions '
          'yourself.',
        ),
      ]);
    }
    return tokens;
  }

  /// Motion for this subtree, already collapsed to zero when the platform asks
  /// for reduced motion.
  DfMotion get dfMotion => df.motion.resolve(this);
}
