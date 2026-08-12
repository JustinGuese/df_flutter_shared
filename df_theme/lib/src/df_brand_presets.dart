import 'package:flutter/material.dart';

import 'df_brand.dart';
import 'df_palette.dart';
import 'df_shape.dart';
import 'df_typography.dart';

/// Ready-made brands.
///
/// [dataFortress] is the house style — start here for a new app, then override
/// what the product actually needs. The per-app presets exist so the five
/// existing apps can migrate onto `DfTheme` without changing how they look.
abstract final class DfBrandPresets {
  // ---------------------------------------------------------------------------
  // The DataFortress house style: "Ledger".
  //
  // Every DF app is a record of something — a diary entry, a care assessment,
  // a document, an order book, a quest log. So the house look is ink on paper
  // with a brass fitting: warm neutrals rather than the cool Tailwind slate
  // that most product UI defaults to, a brass brand colour that sits next to
  // navy, violet, indigo and gold without fighting any of them, and a
  // verdigris counterweight to keep it from reading as a law firm.
  // ---------------------------------------------------------------------------

  static const Color _ink = Color(0xFF1C1917);
  static const Color _paper = Color(0xFFFAF8F5);
  static const Color _brass = Color(0xFFA8781F);
  static const Color _verdigris = Color(0xFF2F6F6B);

  /// The DataFortress house brand. Fonts must be provided by the app — see
  /// [dataFortressFonts] for the intended families.
  static DfBrand dataFortress({DfTypography? typography, String? logoAsset}) =>
      DfBrand(
        name: 'DataFortress',
        light: dataFortressLight,
        dark: dataFortressDark,
        typography: typography ?? const DfTypography.system(),
        logoAsset: logoAsset,
      );

  /// The families the house style is designed around.
  ///
  /// Fraunces is a variable serif with real character — bookish and slightly
  /// odd — without being the high-contrast Didone that generic "editorial"
  /// design reaches for. Public Sans was drawn for government forms, which is
  /// exactly the density and legibility NaviCare's older users need. JetBrains
  /// Mono carries the figures.
  ///
  /// The app must actually ship these; Flutter falls back to the platform font
  /// silently, which keeps the layout but loses the identity.
  static const DfTypography dataFortressFonts = DfTypography(
    display: 'Fraunces',
    body: 'Public Sans',
    mono: 'JetBrains Mono',
  );

  static final DfPalette dataFortressLight = DfPalette(
    brightness: Brightness.light,
    canvas: _paper,
    surface: const Color(0xFFFFFFFF),
    surfaceElevated: const Color(0xFFFFFFFF),
    surfaceSunken: const Color(0xFFF2EEE8),
    hairline: const Color(0xFFE4DED4),
    border: const Color(0xFFD5CCBE),
    textPrimary: _ink,
    textSecondary: const Color(0xFF57504A),
    textTertiary: const Color(0xFF847B72),
    textDisabled: const Color(0xFFB0A79D),
    textOnBrand: const Color(0xFFFFFFFF),
    // `deep` is what fills buttons: the mid-tone brass only reaches ~4.0:1
    // against white, which is under the 4.5:1 needed for button labels.
    brand: const DfBrandRoleTriad(
      base: _brass,
      deep: Color(0xFF8F6416),
      soft: Color(0xFFDCC189),
      container: Color(0xFFF6EBD5),
      onContainer: Color(0xFF553B08),
    ),
    accent: const DfBrandRoleTriad(
      base: _verdigris,
      deep: Color(0xFF235350),
      soft: Color(0xFF8FBFBC),
      container: Color(0xFFDCEDEC),
      onContainer: Color(0xFF17403D),
    ),
    success: const DfColorRole(
      base: Color(0xFF3F7D4E),
      deep: Color(0xFF2C5C39),
      soft: Color(0xFF9DC6A8),
      bg: Color(0xFFE6F2E9),
    ),
    warning: const DfColorRole(
      base: Color(0xFFBE6A0A),
      deep: Color(0xFF8A4C06),
      soft: Color(0xFFE8BC85),
      bg: Color(0xFFFBEEDC),
    ),
    error: const DfColorRole(
      base: Color(0xFFA5322A),
      deep: Color(0xFF7C231D),
      soft: Color(0xFFDFA29D),
      bg: Color(0xFFF9E7E5),
    ),
    info: const DfColorRole(
      base: _verdigris,
      deep: Color(0xFF235350),
      soft: Color(0xFF8FBFBC),
      bg: Color(0xFFDCEDEC),
    ),
    gradients: const <String, List<Color>>{
      'header': <Color>[Color(0xFF2F6F6B), Color(0xFF1C4A47)],
      'hero': <Color>[Color(0xFFC08F2C), Color(0xFF8F6416)],
    },
  );

  static final DfPalette dataFortressDark = DfPalette(
    brightness: Brightness.dark,
    // Warm near-black, never #000 — the dark end of the same ink.
    canvas: const Color(0xFF141210),
    surface: const Color(0xFF1E1B18),
    surfaceElevated: const Color(0xFF272320),
    surfaceSunken: const Color(0xFF100E0C),
    hairline: const Color(0xFF302B26),
    border: const Color(0xFF453E37),
    textPrimary: const Color(0xFFF5F2ED),
    textSecondary: const Color(0xFFBDB4A9),
    textTertiary: const Color(0xFF8E857B),
    textDisabled: const Color(0xFF5E564E),
    textOnBrand: const Color(0xFF141210),
    brand: const DfBrandRoleTriad(
      base: Color(0xFFD9A441),
      deep: Color(0xFFB8862C),
      soft: Color(0xFF6E5320),
      container: Color(0xFF3A2C11),
      onContainer: Color(0xFFF0DCAF),
    ),
    accent: const DfBrandRoleTriad(
      base: Color(0xFF4FA39D),
      deep: Color(0xFF357F7A),
      soft: Color(0xFF2A5C58),
      container: Color(0xFF14332F),
      onContainer: Color(0xFFB6DEDA),
    ),
    success: const DfColorRole(
      base: Color(0xFF6FAF7C),
      deep: Color(0xFF4C8A5A),
      soft: Color(0xFF2E4F36),
      bg: Color(0xFF17281B),
    ),
    warning: const DfColorRole(
      base: Color(0xFFE0A15B),
      deep: Color(0xFFB87B36),
      soft: Color(0xFF5C4322),
      bg: Color(0xFF2C1F10),
    ),
    error: const DfColorRole(
      base: Color(0xFFD9736A),
      deep: Color(0xFFAE4C43),
      soft: Color(0xFF5C2B27),
      bg: Color(0xFF2C1513),
    ),
    info: const DfColorRole(
      base: Color(0xFF4FA39D),
      deep: Color(0xFF357F7A),
      soft: Color(0xFF2A5C58),
      bg: Color(0xFF14332F),
    ),
    gradients: const <String, List<Color>>{
      'header': <Color>[Color(0xFF2A5C58), Color(0xFF14332F)],
      'hero': <Color>[Color(0xFFD9A441), Color(0xFF8F6416)],
    },
  );

  // ---------------------------------------------------------------------------
  // Per-app presets. These reproduce each app's existing look so migration to
  // DfTheme is a refactor, not a redesign.
  // ---------------------------------------------------------------------------

  /// NaviCare Now — light, navy + coral, PlusJakartaSans/Inter (bundled).
  static DfBrand naviCare({String? logoAsset}) => DfBrand(
    name: 'NaviCare Now',
    light: naviCareLight,
    // NaviCare ships light-only today; this dark palette is a starting
    // point so the app can opt in rather than a mode it already supports.
    dark: _deriveDark(naviCareLight),
    typography: const DfTypography(
      display: 'PlusJakartaSans',
      body: 'Inter',
      mono: 'JetBrains Mono',
    ),
    logoAsset: logoAsset,
  );

  static final DfPalette naviCareLight = DfPalette(
    brightness: Brightness.light,
    canvas: const Color(0xFFF8FAFC),
    surface: const Color(0xFFFFFFFF),
    surfaceElevated: const Color(0xFFFFFFFF),
    surfaceSunken: const Color(0xFFF1F5F9),
    hairline: const Color(0xFFE2E8F0),
    border: const Color(0xFFCBD5E1),
    textPrimary: const Color(0xFF0F172A),
    textSecondary: const Color(0xFF475569),
    textTertiary: const Color(0xFF64748B),
    textDisabled: const Color(0xFF94A3B8),
    textOnBrand: const Color(0xFFFFFFFF),
    brand: const DfBrandRoleTriad(
      base: Color(0xFF16477E),
      deep: Color(0xFF0D2E52),
      soft: Color(0xFF2E6BAA),
      container: Color(0xFFE3EDF8),
      onContainer: Color(0xFF0D2E52),
    ),
    accent: const DfBrandRoleTriad(
      base: Color(0xFFE86A5C),
      deep: Color(0xFFD4523F),
      soft: Color(0xFFF3A399),
      container: Color(0xFFFCE9E6),
      onContainer: Color(0xFF8A2E22),
    ),
    success: const DfColorRole(
      base: Color(0xFF22C55E),
      deep: Color(0xFF15803D),
      soft: Color(0xFF86EFAC),
      bg: Color(0xFFE7F8ED),
    ),
    warning: const DfColorRole(
      base: Color(0xFFF59E0B),
      deep: Color(0xFF92400E),
      soft: Color(0xFFFCD34D),
      bg: Color(0xFFFEF3E2),
    ),
    error: const DfColorRole(
      base: Color(0xFFEF4444),
      deep: Color(0xFFB91C1C),
      soft: Color(0xFFFCA5A5),
      bg: Color(0xFFFDEDED),
    ),
    info: const DfColorRole(
      base: Color(0xFF2DCDC8),
      deep: Color(0xFF1FA39F),
      soft: Color(0xFF8FE6E2),
      bg: Color(0xFFE9F6F6),
    ),
    gradients: const <String, List<Color>>{
      'header': <Color>[
        Color(0xFF2E6BAA),
        Color(0xFF16477E),
        Color(0xFF0D2E52),
      ],
    },
  );

  /// PsychDiary — violet, Inter, light + dark.
  static DfBrand psychDiary({String? logoAsset}) => DfBrand(
    name: 'PsychDiary',
    light: psychDiaryLight,
    dark: psychDiaryDark,
    typography: const DfTypography(body: 'Inter', mono: 'JetBrains Mono'),
    shape: const DfShape(sm: 12, md: 20, lg: 24, xl: 28),
    logoAsset: logoAsset,
  );

  static final DfPalette psychDiaryLight = DfPalette(
    brightness: Brightness.light,
    canvas: const Color(0xFFFAFAFA),
    surface: const Color(0xFFFFFFFF),
    surfaceElevated: const Color(0xFFFFFFFF),
    surfaceSunken: const Color(0xFFF5F5F7),
    hairline: const Color(0xFFE5E7EB),
    border: const Color(0xFFD1D5DB),
    textPrimary: const Color(0xFF111827),
    textSecondary: const Color(0xFF6B7280),
    textTertiary: const Color(0xFF9CA3AF),
    textDisabled: const Color(0xFFC4C8CF),
    textOnBrand: const Color(0xFFFFFFFF),
    brand: const DfBrandRoleTriad(
      base: Color(0xFF7C3AED),
      deep: Color(0xFF6D28D9),
      soft: Color(0xFFC4B5FD),
      container: Color(0xFFEDE9FE),
      onContainer: Color(0xFF2E1065),
    ),
    accent: const DfBrandRoleTriad(
      base: Color(0xFF4F46E5),
      deep: Color(0xFF4338CA),
      soft: Color(0xFFA5B4FC),
      container: Color(0xFFE0E7FF),
      onContainer: Color(0xFF1E1B4B),
    ),
    success: const DfColorRole(
      base: Color(0xFF10B981),
      deep: Color(0xFF047857),
      soft: Color(0xFF6EE7B7),
      bg: Color(0xFFECFDF5),
    ),
    warning: const DfColorRole(
      base: Color(0xFFF59E0B),
      deep: Color(0xFF92400E),
      soft: Color(0xFFFCD34D),
      bg: Color(0xFFFEF3C7),
    ),
    error: const DfColorRole(
      base: Color(0xFFDC2626),
      deep: Color(0xFF991B1B),
      soft: Color(0xFFFCA5A5),
      bg: Color(0xFFFEF2F2),
    ),
    info: const DfColorRole(
      base: Color(0xFF3B82F6),
      deep: Color(0xFF1D4ED8),
      soft: Color(0xFF93C5FD),
      bg: Color(0xFFEFF6FF),
    ),
    gradients: const <String, List<Color>>{
      'header': <Color>[Color(0xFF8B5CF6), Color(0xFF6366F1)],
      'streak': <Color>[Color(0xFFF59E0B), Color(0xFFD97706)],
      'calm': <Color>[Color(0xFF3B82F6), Color(0xFF06B6D4)],
    },
  );

  static final DfPalette psychDiaryDark = psychDiaryLight.copyWith(
    brightness: Brightness.dark,
    canvas: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    surfaceElevated: const Color(0xFF2C2C2C),
    surfaceSunken: const Color(0xFF0C0C0C),
    hairline: const Color(0xFF2F2F2F),
    border: const Color(0xFF3F3F46),
    textPrimary: const Color(0xFFE5E7EB),
    textSecondary: const Color(0xFF9CA3AF),
    textTertiary: const Color(0xFF6B7280),
    textDisabled: const Color(0xFF4B5563),
    brand: const DfBrandRoleTriad(
      base: Color(0xFF9F75F5),
      deep: Color(0xFF7C3AED),
      soft: Color(0xFF4C2C8F),
      container: Color(0xFF2E1065),
      onContainer: Color(0xFFDDD1FB),
    ),
  );

  /// TileDom — dark, gold on abyss. Games keep their own identity; only the
  /// structure (spacing, radii, motion, role names) is shared.
  static DfBrand tileDom({String? logoAsset}) => DfBrand(
    name: 'TileDom',
    light: tileDomDark,
    dark: tileDomDark,
    typography: const DfTypography(
      display: 'Syne',
      body: 'Sora',
      mono: 'Space Mono',
    ),
    shape: const DfShape(sm: 8, md: 16, lg: 24, xl: 28),
    logoAsset: logoAsset,
  );

  static final DfPalette tileDomDark = DfPalette(
    brightness: Brightness.dark,
    canvas: const Color(0xFF0A0F14),
    surface: const Color(0xFF131C24),
    surfaceElevated: const Color(0xFF1B2530),
    surfaceSunken: const Color(0xFF060A0E),
    hairline: const Color(0xFF2A3742),
    border: const Color(0xFF3A4A57),
    textPrimary: const Color(0xFFEAF2F0),
    textSecondary: const Color(0xFF8A9BA6),
    textTertiary: const Color(0xFF6B7A84),
    textDisabled: const Color(0xFF4A555D),
    textOnBrand: const Color(0xFF0A0F14),
    brand: const DfBrandRoleTriad(
      base: Color(0xFFFFC64B),
      deep: Color(0xFFE0A427),
      soft: Color(0xFF7A5F1C),
      container: Color(0xFF3A2D0E),
      onContainer: Color(0xFFFFE3A8),
    ),
    accent: const DfBrandRoleTriad(
      base: Color(0xFF38BDF8),
      deep: Color(0xFF0C93CC),
      soft: Color(0xFF1D4E63),
      container: Color(0xFF102C38),
      onContainer: Color(0xFFB4E5FB),
    ),
    success: const DfColorRole(
      base: Color(0xFF4ADE80),
      deep: Color(0xFF22A25A),
      soft: Color(0xFF215B36),
      bg: Color(0xFF0F2A1B),
    ),
    warning: const DfColorRole(
      base: Color(0xFFFFC64B),
      deep: Color(0xFFE0A427),
      soft: Color(0xFF6E561C),
      bg: Color(0xFF2A2110),
    ),
    error: const DfColorRole(
      base: Color(0xFFFF6B4A),
      deep: Color(0xFFD1462A),
      soft: Color(0xFF6B2C1E),
      bg: Color(0xFF2C1610),
    ),
    info: const DfColorRole(
      base: Color(0xFFA78BFA),
      deep: Color(0xFF7C5CE0),
      soft: Color(0xFF473A6B),
      bg: Color(0xFF1E1832),
    ),
    gradients: const <String, List<Color>>{
      'header': <Color>[Color(0xFF1B2530), Color(0xFF0A0F14)],
      'hero': <Color>[Color(0xFFE0A427), Color(0xFF8A6212)],
    },
  );

  /// SocialAnxify — retro pixel, gold on night purple. Square corners: the
  /// pixel identity rejects rounding.
  static DfBrand socialAnxify({String? logoAsset}) => DfBrand(
    name: 'SocialAnxify',
    light: socialAnxifyDark,
    dark: socialAnxifyDark,
    typography: const DfTypography(
      display: 'Press Start 2P',
      body: 'Press Start 2P',
      mono: 'Press Start 2P',
      // Press Start 2P is enormous at nominal size; the whole scale is
      // pulled down rather than every call site passing a literal.
      scale: 0.68,
    ),
    shape: const DfShape.sharp(),
    logoAsset: logoAsset,
  );

  static final DfPalette socialAnxifyDark = DfPalette(
    brightness: Brightness.dark,
    canvas: const Color(0xFF1A1033),
    surface: const Color(0xFF2A1B4F),
    surfaceElevated: const Color(0xFF372563),
    surfaceSunken: const Color(0xFF15092B),
    hairline: const Color(0xFF8A6B1A),
    border: const Color(0xFFFFD86B),
    textPrimary: const Color(0xFFF5E9D6),
    textSecondary: const Color(0xFFB0A2C9),
    textTertiary: const Color(0xFF8E80A8),
    textDisabled: const Color(0xFF6A5E82),
    textOnBrand: const Color(0xFF1A1033),
    brand: const DfBrandRoleTriad(
      base: Color(0xFFFFD86B),
      deep: Color(0xFFD9B03F),
      soft: Color(0xFF8A6B1A),
      container: Color(0xFF3D2A6B),
      onContainer: Color(0xFFFFD86B),
    ),
    accent: const DfBrandRoleTriad(
      base: Color(0xFF6BFFB0),
      deep: Color(0xFF3AD087),
      soft: Color(0xFF2A6B4C),
      container: Color(0xFF163A2A),
      onContainer: Color(0xFFB6FFDA),
    ),
    success: const DfColorRole(
      base: Color(0xFF6BFFB0),
      deep: Color(0xFF3AD087),
      soft: Color(0xFF2A6B4C),
      bg: Color(0xFF163A2A),
    ),
    warning: const DfColorRole(
      base: Color(0xFFFF9E4D),
      deep: Color(0xFFD97A2A),
      soft: Color(0xFF6B4527),
      bg: Color(0xFF3A2415),
    ),
    error: const DfColorRole(
      base: Color(0xFFFF4D6D),
      deep: Color(0xFFD62A4B),
      soft: Color(0xFF6B2231),
      bg: Color(0xFF3A121F),
    ),
    info: const DfColorRole(
      base: Color(0xFF6BC4FF),
      deep: Color(0xFF3A9AD9),
      soft: Color(0xFF2A526B),
      bg: Color(0xFF14293A),
    ),
    gradients: const <String, List<Color>>{
      'header': <Color>[Color(0xFF3D2A6B), Color(0xFF1A1033)],
      'hero': <Color>[Color(0xFF2A1B4F), Color(0xFF15092B)],
    },
  );

  /// DocumentChat — indigo, Inter. Had no palette file at all; this formalises
  /// the seed colour it was using and gives it a dark mode.
  static DfBrand documentChat({String? logoAsset}) => DfBrand(
    name: 'DocumentChat',
    light: documentChatLight,
    dark: _deriveDark(documentChatLight),
    typography: const DfTypography(body: 'Inter', mono: 'JetBrains Mono'),
    logoAsset: logoAsset,
  );

  static final DfPalette documentChatLight = DfPalette(
    brightness: Brightness.light,
    canvas: const Color(0xFFF2F2F7),
    surface: const Color(0xFFFFFFFF),
    surfaceElevated: const Color(0xFFFFFFFF),
    surfaceSunken: const Color(0xFFE9E9EF),
    hairline: const Color(0xFFE2E2E8),
    border: const Color(0xFFCFCFD6),
    textPrimary: const Color(0xFF11111A),
    textSecondary: const Color(0xFF5A5A66),
    textTertiary: const Color(0xFF8A8A95),
    textDisabled: const Color(0xFFB4B4BD),
    textOnBrand: const Color(0xFFFFFFFF),
    brand: const DfBrandRoleTriad(
      base: Color(0xFF5856D6),
      deep: Color(0xFF4341B8),
      soft: Color(0xFFAFAEEC),
      container: Color(0xFFE8E8FA),
      onContainer: Color(0xFF23227A),
    ),
    accent: const DfBrandRoleTriad(
      base: Color(0xFF0A84FF),
      deep: Color(0xFF0062CC),
      soft: Color(0xFF8CC4FF),
      container: Color(0xFFE1EFFF),
      onContainer: Color(0xFF00366F),
    ),
    success: const DfColorRole(
      base: Color(0xFF34C759),
      deep: Color(0xFF1F8F3D),
      soft: Color(0xFF97E5AC),
      bg: Color(0xFFE8F8EC),
    ),
    warning: const DfColorRole(
      base: Color(0xFFFF9500),
      deep: Color(0xFFB86B00),
      soft: Color(0xFFFFCE85),
      bg: Color(0xFFFFF2E0),
    ),
    error: const DfColorRole(
      base: Color(0xFFFF3B30),
      deep: Color(0xFFC1170D),
      soft: Color(0xFFFFA49E),
      bg: Color(0xFFFFEBEA),
    ),
    info: const DfColorRole(
      base: Color(0xFF0A84FF),
      deep: Color(0xFF0062CC),
      soft: Color(0xFF8CC4FF),
      bg: Color(0xFFE1EFFF),
    ),
    gradients: const <String, List<Color>>{
      'header': <Color>[Color(0xFF4341B8), Color(0xFF2B2A8C)],
    },
  );

  /// Flips a light palette to a usable dark one.
  ///
  /// A starting point for apps that have never shipped dark mode, not a
  /// substitute for hand-tuning it. Brand and accent are lightened so they
  /// hold contrast against a dark canvas.
  static DfPalette _deriveDark(DfPalette light) {
    Color lighten(Color c, double amount) {
      final hsl = HSLColor.fromColor(c);
      return hsl
          .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
          .toColor();
    }

    return light.copyWith(
      brightness: Brightness.dark,
      canvas: const Color(0xFF121316),
      surface: const Color(0xFF1B1D21),
      surfaceElevated: const Color(0xFF24262B),
      surfaceSunken: const Color(0xFF0D0E10),
      hairline: const Color(0xFF2C2F35),
      border: const Color(0xFF41454D),
      textPrimary: const Color(0xFFECEDEF),
      textSecondary: const Color(0xFFA8ADB5),
      textTertiary: const Color(0xFF7B8189),
      textDisabled: const Color(0xFF565B62),
      textOnBrand: const Color(0xFF121316),
      brand: light.brand.copyWith(
        base: lighten(light.brand.base, 0.18),
        deep: light.brand.base,
        soft: lighten(light.brand.base, -0.18),
        container: lighten(light.brand.base, -0.32),
        onContainer: lighten(light.brand.base, 0.34),
      ),
      accent: light.accent.copyWith(
        base: lighten(light.accent.base, 0.16),
        deep: light.accent.base,
        soft: lighten(light.accent.base, -0.18),
        container: lighten(light.accent.base, -0.32),
        onContainer: lighten(light.accent.base, 0.34),
      ),
    );
  }
}
