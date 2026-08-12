import 'package:flutter/material.dart';

import 'df_brand.dart';
import 'df_tokens.dart';

/// Builds [ThemeData] from a [DfBrand].
///
/// This is the component layer of the design system: every app used to
/// hand-write ~70 lines of `ThemeData` per mode, and they drifted. Passing a
/// brand through here produces the same component shapes everywhere, so the
/// apps differ in palette and type rather than in how a button is built.
abstract final class DfTheme {
  static ThemeData light(DfBrand brand) => _build(brand, Brightness.light);

  static ThemeData dark(DfBrand brand) => _build(brand, Brightness.dark);

  /// Both modes at once, for `MaterialApp(theme:, darkTheme:)`.
  static ({ThemeData light, ThemeData dark}) both(DfBrand brand) =>
      (light: light(brand), dark: dark(brand));

  static ThemeData _build(DfBrand brand, Brightness brightness) {
    final p = brand.paletteFor(brightness);
    final shape = brand.shape;
    final spacing = brand.spacing;
    final text = brand.typography.buildTextTheme(
      p.textPrimary,
      p.textSecondary,
    );

    final tokens = DfTokens(
      brandName: brand.name,
      colors: p,
      typography: brand.typography,
      spacing: spacing,
      shape: shape,
      motion: brand.motion,
      logoAsset: brand.logoAsset,
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.brandFill,
      onPrimary: p.textOnBrand,
      primaryContainer: p.brand.container,
      onPrimaryContainer: p.brand.onContainer,
      secondary: p.accent.base,
      onSecondary: p.textOnBrand,
      secondaryContainer: p.accent.container,
      onSecondaryContainer: p.accent.onContainer,
      tertiary: p.info.base,
      onTertiary: p.textOnBrand,
      error: p.error.base,
      onError: Colors.white,
      errorContainer: p.error.bg,
      onErrorContainer: p.error.deep,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerLowest: p.surfaceSunken,
      surfaceContainerLow: p.canvas,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceElevated,
      surfaceContainerHighest: p.surfaceElevated,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      outlineVariant: p.hairline,
      shadow: Colors.black,
      inverseSurface: p.textPrimary,
      onInverseSurface: p.surface,
      inversePrimary: p.brand.soft,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      dividerColor: p.hairline,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[tokens],
      fontFamily: brand.typography.body,

      appBarTheme: AppBarTheme(
        backgroundColor: p.canvas,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: p.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: shape.radiusMd,
          side: BorderSide(color: p.hairline),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: p.hairline,
        thickness: 1,
        space: spacing.lg,
      ),

      // Primary action. `brandFill` rather than `brand.base` — a mid-tone brand
      // colour rarely clears 4.5:1 against white text in light mode.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.brandFill,
          foregroundColor: p.textOnBrand,
          // A disabled button reads as inert, not as a tinted live one. Using
          // brand.soft here left the label at roughly 1.6:1 against the fill.
          disabledBackgroundColor: p.surfaceSunken,
          disabledForegroundColor: p.textDisabled,
          minimumSize: const Size(0, 52),
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          shape: RoundedRectangleBorder(borderRadius: shape.radiusButton),
          textStyle: text.labelLarge,
          elevation: 0,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.brandFill,
          foregroundColor: p.textOnBrand,
          minimumSize: const Size(0, 52),
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          shape: RoundedRectangleBorder(borderRadius: shape.radiusButton),
          textStyle: text.labelLarge,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          minimumSize: const Size(0, 52),
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(borderRadius: shape.radiusButton),
          textStyle: text.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent.deep,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          shape: RoundedRectangleBorder(borderRadius: shape.radiusSm),
          textStyle: text.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.textSecondary,
          shape: RoundedRectangleBorder(borderRadius: shape.radiusSm),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceSunken,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm + 2,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: p.textTertiary),
        labelStyle: text.bodyMedium?.copyWith(color: p.textSecondary),
        floatingLabelStyle: text.labelMedium?.copyWith(color: p.accent.deep),
        border: OutlineInputBorder(
          borderRadius: shape.radiusInput,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: shape.radiusInput,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: shape.radiusInput,
          borderSide: BorderSide(color: p.accent.base, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: shape.radiusInput,
          borderSide: BorderSide(color: p.error.base),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: shape.radiusInput,
          borderSide: BorderSide(color: p.error.base, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceSunken,
        selectedColor: p.brand.container,
        side: BorderSide(color: p.hairline),
        // Explicitly untracked: labelMedium carries letter-spacing so it can
        // serve as an eyebrow, but tracking on a chip label just makes a short
        // word look loose.
        labelStyle: text.labelMedium!.copyWith(
          color: p.textSecondary,
          letterSpacing: 0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xxs,
        ),
        shape: RoundedRectangleBorder(borderRadius: shape.radiusPill),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: shape.radiusLg),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: p.border,
        shape: RoundedRectangleBorder(borderRadius: shape.radiusSheet),
      ),

      // Inverted, so a snackbar reads as a system message rather than another
      // card. Actions use the brand so they stay recognisably tappable.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.surface),
        actionTextColor: p.brand.soft,
        behavior: SnackBarBehavior.floating,
        insetPadding: EdgeInsets.all(spacing.md),
        shape: RoundedRectangleBorder(borderRadius: shape.radiusSm),
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.brand.container,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? text.labelSmall!.copyWith(color: p.brand.deep)
              : text.labelSmall!.copyWith(color: p.textTertiary),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? p.brand.deep
                : p.textTertiary,
          ),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: p.brand.deep,
        unselectedLabelColor: p.textTertiary,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
        indicatorColor: p.brand.base,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: p.hairline,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        contentPadding: EdgeInsets.symmetric(horizontal: spacing.md),
        shape: RoundedRectangleBorder(borderRadius: shape.radiusSm),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.textOnBrand : p.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.brandFill
              : p.surfaceSunken,
        ),
        trackOutlineColor: WidgetStatePropertyAll<Color>(p.border),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.brandFill
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll<Color>(p.textOnBrand),
        side: BorderSide(color: p.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.brandFill : p.border,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: p.brandFill,
        inactiveTrackColor: p.surfaceSunken,
        thumbColor: p.brandFill,
        overlayColor: p.brand.base.withValues(alpha: 0.12),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.brand.base,
        linearTrackColor: p.surfaceSunken,
        circularTrackColor: p.surfaceSunken,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.textPrimary,
          borderRadius: shape.radiusSm,
        ),
        textStyle: text.bodySmall?.copyWith(color: p.surface),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: p.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: shape.radiusInput,
          side: BorderSide(color: p.hairline),
        ),
        textStyle: text.bodyMedium,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.brandFill,
        foregroundColor: p.textOnBrand,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: shape.radiusMd),
      ),

      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );
  }
}
