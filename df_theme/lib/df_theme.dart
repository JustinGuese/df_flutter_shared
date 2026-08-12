/// The DataFortress design system.
///
/// Apps define one [DfBrand] and build their `ThemeData` from it:
///
/// ```dart
/// final brand = DfBrandPresets.dataFortress(
///   typography: DfBrandPresets.dataFortressFonts,
///   logoAsset: 'assets/images/logo.png',
/// );
///
/// MaterialApp(
///   theme: DfTheme.light(brand),
///   darkTheme: DfTheme.dark(brand),
///   themeMode: ThemeMode.system,
/// );
/// ```
///
/// Widgets then read tokens through `context.df` rather than naming colours:
///
/// ```dart
/// Container(
///   padding: EdgeInsets.all(context.df.spacing.md),
///   decoration: BoxDecoration(
///     color: context.df.colors.surface,
///     borderRadius: context.df.shape.radiusMd,
///     boxShadow: context.df.cardShadow,
///   ),
/// )
/// ```
///
/// That indirection is the point: one shared widget can serve NaviCare's light
/// navy and TileDom's dark gold without branching on the app.
library;

export 'src/df_brand.dart';
export 'src/df_brand_presets.dart';
export 'src/df_motion.dart';
export 'src/df_palette.dart';
export 'src/df_shape.dart';
export 'src/df_spacing.dart';
export 'src/df_theme_builder.dart';
export 'src/df_tokens.dart';
export 'src/df_typography.dart';
