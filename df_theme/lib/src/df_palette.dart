import 'package:flutter/material.dart';

/// One semantic colour, in the four weights every DF surface needs.
///
/// Splitting a role into weights is what lets a brand colour stay recognisable
/// while still meeting contrast. [base] is the identity colour; [deep] is the
/// one that actually fills a button in light mode (a mid-tone brand colour
/// rarely clears 4.5:1 against white); [soft] tints borders and icons; [bg]
/// is the wash behind a banner or badge.
@immutable
class DfColorRole {
  const DfColorRole({
    required this.base,
    required this.deep,
    required this.soft,
    required this.bg,
  });

  /// Builds a role from a single colour by shading it.
  ///
  /// Convenient for app brands that only have one swatch; hand-pick the four
  /// weights when the role carries brand meaning.
  factory DfColorRole.from(
    Color base, {
    Brightness brightness = Brightness.light,
  }) {
    final hsl = HSLColor.fromColor(base);
    final isDark = brightness == Brightness.dark;
    return DfColorRole(
      base: base,
      deep: hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor(),
      soft: hsl
          .withLightness(
            (hsl.lightness + (isDark ? -0.22 : 0.26)).clamp(0.0, 1.0),
          )
          .toColor(),
      bg: hsl
          .withLightness((isDark ? 0.16 : 0.95))
          .withSaturation(
            (hsl.saturation * (isDark ? 0.5 : 0.6)).clamp(0.0, 1.0),
          )
          .toColor(),
    );
  }

  /// The identity colour. Use for large text, icons and accents.
  final Color base;

  /// Darkened. Fills primary buttons in light mode; use for text on [bg].
  final Color deep;

  /// Lightened. Borders, dividers, disabled states.
  final Color soft;

  /// A wash to sit behind [deep] text — banners, badges, callouts.
  final Color bg;

  DfColorRole copyWith({Color? base, Color? deep, Color? soft, Color? bg}) =>
      DfColorRole(
        base: base ?? this.base,
        deep: deep ?? this.deep,
        soft: soft ?? this.soft,
        bg: bg ?? this.bg,
      );

  static DfColorRole lerp(DfColorRole a, DfColorRole b, double t) =>
      DfColorRole(
        base: Color.lerp(a.base, b.base, t)!,
        deep: Color.lerp(a.deep, b.deep, t)!,
        soft: Color.lerp(a.soft, b.soft, t)!,
        bg: Color.lerp(a.bg, b.bg, t)!,
      );
}

/// Every colour a DF app is allowed to name.
///
/// Widgets read these roles instead of literals, which is what lets one widget
/// serve NaviCare's light navy and TileDom's dark gold without a branch.
@immutable
class DfPalette {
  const DfPalette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.hairline,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnBrand,
    required this.brand,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    this.gradients = const <String, List<Color>>{},
  });

  /// Derives a full palette from a plain Material [ColorScheme].
  ///
  /// The bridge for apps that have not adopted [DfBrand] yet: a df_* widget
  /// asking for tokens inside an un-migrated app gets something derived from
  /// that app's own theme rather than a crash or another app's brand. Migration
  /// across five apps has to be incremental, so shared widgets must not require
  /// the whole design system to be wired up first.
  ///
  /// Hand-authored palettes are still better — this one has no separate canvas
  /// tone and guesses the semantic ramps.
  factory DfPalette.fromColorScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

    return DfPalette(
      brightness: scheme.brightness,
      canvas: scheme.surface,
      surface: scheme.surfaceContainerLow,
      surfaceElevated: scheme.surfaceContainerHigh,
      surfaceSunken: scheme.surfaceContainerLowest,
      hairline: scheme.outlineVariant,
      border: scheme.outline,
      textPrimary: scheme.onSurface,
      textSecondary: scheme.onSurfaceVariant,
      textTertiary: mix(scheme.onSurfaceVariant, scheme.surface, 0.30),
      textDisabled: mix(scheme.onSurfaceVariant, scheme.surface, 0.55),
      textOnBrand: scheme.onPrimary,
      brand: DfBrandRoleTriad(
        base: scheme.primary,
        deep: mix(scheme.primary, Colors.black, isDark ? 0.0 : 0.18),
        soft: mix(scheme.primary, scheme.surface, 0.55),
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
      ),
      accent: DfBrandRoleTriad(
        base: scheme.secondary,
        deep: mix(scheme.secondary, Colors.black, isDark ? 0.0 : 0.18),
        soft: mix(scheme.secondary, scheme.surface, 0.55),
        container: scheme.secondaryContainer,
        onContainer: scheme.onSecondaryContainer,
      ),
      success: DfColorRole.from(
        const Color(0xFF3F7D4E),
        brightness: scheme.brightness,
      ),
      warning: DfColorRole.from(
        const Color(0xFFBE6A0A),
        brightness: scheme.brightness,
      ),
      // The one semantic role Material actually defines, so use it rather than
      // guessing.
      error: DfColorRole(
        base: scheme.error,
        deep: mix(scheme.error, Colors.black, isDark ? 0.0 : 0.22),
        soft: mix(scheme.error, scheme.surface, 0.55),
        bg: scheme.errorContainer,
      ),
      info: DfColorRole.from(
        const Color(0xFF2F6F6B),
        brightness: scheme.brightness,
      ),
    );
  }

  final Brightness brightness;

  /// The page background. Distinct from [surface] on purpose: DF layouts read
  /// as sheets laid on a desk, so cards must be able to sit *above* the page.
  final Color canvas;
  final Color surface;

  /// Raised above [surface] — menus, sheets, hovered cards.
  final Color surfaceElevated;

  /// Recessed below [surface] — input wells, progress tracks, code blocks.
  final Color surfaceSunken;

  /// 1px separators inside a surface.
  final Color hairline;

  /// Container outlines. Heavier than [hairline].
  final Color border;

  final Color textPrimary;
  final Color textSecondary;

  /// Captions, timestamps, metadata.
  final Color textTertiary;
  final Color textDisabled;

  /// Foreground on top of [brand].deep (light) or [brand].base (dark).
  final Color textOnBrand;

  /// The app's identity colour — primary actions, active states.
  final DfBrandRoleTriad brand;

  /// The counterweight to [brand]. Secondary actions, highlights, links.
  final DfBrandRoleTriad accent;

  final DfColorRole success;
  final DfColorRole warning;
  final DfColorRole error;
  final DfColorRole info;

  /// Named multi-stop gradients (`'header'`, `'hero'`, …). Kept as a map so an
  /// app can add its own without the package knowing about them.
  final Map<String, List<Color>> gradients;

  bool get isDark => brightness == Brightness.dark;

  /// The fill for a primary button, which differs by mode: a mid-tone brand
  /// colour needs darkening on light backgrounds and lightening on dark ones.
  Color get brandFill => isDark ? brand.base : brand.deep;

  List<Color>? gradient(String name) => gradients[name];

  DfPalette copyWith({
    Brightness? brightness,
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSunken,
    Color? hairline,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textOnBrand,
    DfBrandRoleTriad? brand,
    DfBrandRoleTriad? accent,
    DfColorRole? success,
    DfColorRole? warning,
    DfColorRole? error,
    DfColorRole? info,
    Map<String, List<Color>>? gradients,
  }) => DfPalette(
    brightness: brightness ?? this.brightness,
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    surfaceSunken: surfaceSunken ?? this.surfaceSunken,
    hairline: hairline ?? this.hairline,
    border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    textDisabled: textDisabled ?? this.textDisabled,
    textOnBrand: textOnBrand ?? this.textOnBrand,
    brand: brand ?? this.brand,
    accent: accent ?? this.accent,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    info: info ?? this.info,
    gradients: gradients ?? this.gradients,
  );

  static DfPalette lerp(DfPalette a, DfPalette b, double t) => DfPalette(
    brightness: t < 0.5 ? a.brightness : b.brightness,
    canvas: Color.lerp(a.canvas, b.canvas, t)!,
    surface: Color.lerp(a.surface, b.surface, t)!,
    surfaceElevated: Color.lerp(a.surfaceElevated, b.surfaceElevated, t)!,
    surfaceSunken: Color.lerp(a.surfaceSunken, b.surfaceSunken, t)!,
    hairline: Color.lerp(a.hairline, b.hairline, t)!,
    border: Color.lerp(a.border, b.border, t)!,
    textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
    textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
    textTertiary: Color.lerp(a.textTertiary, b.textTertiary, t)!,
    textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
    textOnBrand: Color.lerp(a.textOnBrand, b.textOnBrand, t)!,
    brand: DfBrandRoleTriad.lerp(a.brand, b.brand, t),
    accent: DfBrandRoleTriad.lerp(a.accent, b.accent, t),
    success: DfColorRole.lerp(a.success, b.success, t),
    warning: DfColorRole.lerp(a.warning, b.warning, t),
    error: DfColorRole.lerp(a.error, b.error, t),
    info: DfColorRole.lerp(a.info, b.info, t),
    gradients: t < 0.5 ? a.gradients : b.gradients,
  );
}

/// A brand or accent colour with its container weights.
///
/// Same shape as [DfColorRole] but named for brand use, plus [container] /
/// [onContainer] which Material's `ColorScheme` expects.
@immutable
class DfBrandRoleTriad {
  const DfBrandRoleTriad({
    required this.base,
    required this.deep,
    required this.soft,
    required this.container,
    required this.onContainer,
  });

  factory DfBrandRoleTriad.from(
    Color base, {
    Brightness brightness = Brightness.light,
  }) {
    final hsl = HSLColor.fromColor(base);
    final isDark = brightness == Brightness.dark;
    return DfBrandRoleTriad(
      base: base,
      deep: hsl.withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0)).toColor(),
      soft: hsl
          .withLightness(
            (hsl.lightness + (isDark ? -0.24 : 0.28)).clamp(0.0, 1.0),
          )
          .toColor(),
      container: hsl
          .withLightness(isDark ? 0.20 : 0.92)
          .withSaturation((hsl.saturation * 0.55).clamp(0.0, 1.0))
          .toColor(),
      onContainer: hsl.withLightness(isDark ? 0.88 : 0.20).toColor(),
    );
  }

  final Color base;
  final Color deep;
  final Color soft;
  final Color container;
  final Color onContainer;

  DfBrandRoleTriad copyWith({
    Color? base,
    Color? deep,
    Color? soft,
    Color? container,
    Color? onContainer,
  }) => DfBrandRoleTriad(
    base: base ?? this.base,
    deep: deep ?? this.deep,
    soft: soft ?? this.soft,
    container: container ?? this.container,
    onContainer: onContainer ?? this.onContainer,
  );

  static DfBrandRoleTriad lerp(
    DfBrandRoleTriad a,
    DfBrandRoleTriad b,
    double t,
  ) => DfBrandRoleTriad(
    base: Color.lerp(a.base, b.base, t)!,
    deep: Color.lerp(a.deep, b.deep, t)!,
    soft: Color.lerp(a.soft, b.soft, t)!,
    container: Color.lerp(a.container, b.container, t)!,
    onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
  );
}
