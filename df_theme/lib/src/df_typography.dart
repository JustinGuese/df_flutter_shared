import 'package:flutter/material.dart';

/// The three type roles every DF app uses.
///
/// This package names font *families* rather than loading them, because
/// consumers disagree on how fonts arrive: NaviCare bundles variable `.ttf`s,
/// everyone else uses `google_fonts`, and the two live on incompatible major
/// versions. Depending on `google_fonts` here would force a resolution
/// conflict, so the choice stays with the app.
///
/// Supply families one of two ways:
///
/// ```dart
/// // 1. Bundled fonts declared in the app's pubspec.
/// const DfTypography(display: 'Fraunces', body: 'Public Sans', mono: 'JetBrains Mono')
///
/// // 2. google_fonts, by handing over a ready-made TextTheme.
/// DfTypography.fromTextTheme(
///   GoogleFonts.publicSansTextTheme(),
///   display: GoogleFonts.fraunces().fontFamily,
///   mono: GoogleFonts.jetBrainsMono().fontFamily,
/// )
/// ```
///
/// If a named family is not actually available, Flutter silently falls back to
/// the platform font — the layout survives but the identity does not, so verify
/// the app really ships the fonts it names.
@immutable
class DfTypography {
  const DfTypography({
    this.display,
    this.body,
    this.mono,
    this.baseTextTheme,
    this.scale = 1.0,
  });

  /// Uses the platform default for every role.
  ///
  /// A deliberate escape hatch for prototypes and tests. Shipping apps should
  /// name real families — the platform font is the one thing guaranteed to make
  /// the app look like every other app.
  const DfTypography.system()
    : display = null,
      body = null,
      mono = null,
      baseTextTheme = null,
      scale = 1.0;

  /// Builds on an existing [TextTheme] — the `google_fonts` path.
  const DfTypography.fromTextTheme(
    TextTheme this.baseTextTheme, {
    this.display,
    this.mono,
    this.scale = 1.0,
  }) : body = null;

  /// Expressive face. Headlines and numbers-as-headlines only — used
  /// everywhere it stops being expressive.
  final String? display;

  /// Workhorse face. Body copy, labels, buttons, form fields.
  final String? body;

  /// Tabular face. Figures, timers, IDs, money, scores.
  final String? mono;

  /// Optional starting point; role families are layered on top of it.
  final TextTheme? baseTextTheme;

  /// Multiplies every font size. For apps that need a denser or roomier feel
  /// without redefining the scale. Accessibility text scaling is handled
  /// separately by Flutter and is not affected by this.
  final double scale;

  double _s(double size) => size * scale;

  /// Figures that keep a fixed advance width, so columns of numbers line up
  /// and a live-updating value does not jitter. DF apps are full of scores,
  /// prices, streaks and timers, so this is correctness rather than polish.
  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// The DF type scale.
  ///
  /// Tight and deliberate rather than a geometric ramp: three display steps,
  /// three title steps, three body steps, two labels, three data steps.
  /// Line heights are generous in the body range — these are reading apps.
  TextTheme buildTextTheme(Color primary, Color secondary) {
    final base = baseTextTheme ?? const TextTheme();

    TextStyle d(double size, {double height = 1.15, double tracking = -0.02}) =>
        TextStyle(
          fontFamily: display ?? body,
          fontSize: _s(size),
          fontWeight: FontWeight.w600,
          height: height,
          letterSpacing: _s(size) * tracking,
          color: primary,
        );

    TextStyle t(double size, {FontWeight weight = FontWeight.w600}) =>
        TextStyle(
          fontFamily: body,
          fontSize: _s(size),
          fontWeight: weight,
          height: 1.3,
          color: primary,
        );

    TextStyle b(double size, {Color? color, double height = 1.55}) => TextStyle(
      fontFamily: body,
      fontSize: _s(size),
      fontWeight: FontWeight.w400,
      height: height,
      color: color ?? primary,
    );

    TextStyle l(double size, {Color? color}) => TextStyle(
      fontFamily: body,
      fontSize: _s(size),
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: _s(size) * 0.04,
      color: color ?? secondary,
    );

    return base.copyWith(
      displayLarge: d(40),
      displayMedium: d(32),
      displaySmall: d(26),
      headlineLarge: d(24, height: 1.2),
      headlineMedium: d(21, height: 1.25),
      // Display face, like the other headlines — the whole headline range must
      // share a face or the hierarchy reads as two unrelated scales.
      headlineSmall: d(19, height: 1.3),
      titleLarge: t(21),
      titleMedium: t(18),
      titleSmall: t(16),
      bodyLarge: b(16),
      bodyMedium: b(15),
      bodySmall: b(13, color: secondary, height: 1.45),
      labelLarge: t(15, weight: FontWeight.w600),
      labelMedium: l(13),
      labelSmall: l(11),
    );
  }

  /// Monospaced, tabular styles for figures. Not part of [TextTheme] — reach
  /// for these via `context.df.dataMedium` and friends.
  TextStyle data(
    double size,
    Color color, {
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: mono,
    fontSize: _s(size),
    fontWeight: weight,
    height: 1.2,
    color: color,
    fontFeatures: tabular,
  );

  /// The eyebrow: small, uppercase, widely tracked.
  ///
  /// Half of the DF section-header signature — a ledger's column heading.
  TextStyle eyebrow(Color color) => TextStyle(
    fontFamily: body,
    fontSize: _s(11),
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: _s(11) * 0.12,
    color: color,
  );

  DfTypography copyWith({
    String? display,
    String? body,
    String? mono,
    TextTheme? baseTextTheme,
    double? scale,
  }) => DfTypography(
    display: display ?? this.display,
    body: body ?? this.body,
    mono: mono ?? this.mono,
    baseTextTheme: baseTextTheme ?? this.baseTextTheme,
    scale: scale ?? this.scale,
  );

  static DfTypography lerp(DfTypography a, DfTypography b, double t) =>
      t < 0.5 ? a : b;
}
