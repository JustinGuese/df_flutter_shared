# df_theme

The DataFortress design system and identity layer.

`df_theme` defines brand configurations and generates full Flutter `ThemeData` instances for light and dark modes. Widgets consume styling tokens via `context.df` rather than hardcoding colours, radii, or spacing, enabling shared components across apps and brand themes.

Part of Layer 0 (L0) in the `df_flutter_shared` architecture. Has no dependencies on higher layers.

---

## Installation

```yaml
dependencies:
  df_theme:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_theme
      ref: main
```

---

## Getting Started

### 1. Define a Brand and Configure MaterialApp

```dart
import 'package:material_ui/material_ui.dart';
import 'package:df_theme/df_theme.dart';

void main() {
  final brand = DfBrandPresets.dataFortress(
    typography: DfBrandPresets.dataFortressFonts,
    logoAsset: 'assets/images/logo.png',
  );

  runApp(
    MaterialApp(
      theme: DfTheme.light(brand),
      darkTheme: DfTheme.dark(brand),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    ),
  );
}
```

### 2. Read Tokens via `context.df`

Shared widgets read tokens through `context.df` rather than naming literal colours or padding:

```dart
Container(
  padding: EdgeInsets.all(context.df.spacing.md),
  decoration: BoxDecoration(
    color: context.df.colors.surface,
    borderRadius: context.df.shape.radiusMd,
    boxShadow: context.df.cardShadow,
  ),
  child: Text(
    'Themed content',
    style: context.df.typography.bodyMd.copyWith(
      color: context.df.colors.textPrimary,
    ),
  ),
)
```

---

## What’s Included

- **`DfBrand`**: Immutable configuration bundling palette (`DfPalette`), typography (`DfTypography`), spacing scale (`DfSpacing`), shapes/radii (`DfShape`), and motion timing (`DfMotion`).
- **`DfBrandPresets`**: Preconfigured brand definitions for shipping DataFortress apps:
  - `DfBrandPresets.dataFortress` (default house style)
  - `DfBrandPresets.naviCare`
  - `DfBrandPresets.psychDiary`
  - `DfBrandPresets.documentChat`
  - `DfBrandPresets.tileDom`
  - `DfBrandPresets.socialAnxify`
- **`DfTheme`**: Generates full Material 3 `ThemeData` for light (`DfTheme.light(brand)`) and dark (`DfTheme.dark(brand)`) modes, including sub-themes for app bars, buttons, cards, text fields, dialogs, and navigation.
- **`DfTokens`**: `ThemeExtension` accessible via `context.df`:
  - `context.df.colors` — semantic palette (`brand.base`, `brand.subtle`, `surface`, `surfaceSubtle`, `textPrimary`, `textSecondary`, `border`, `error`, `success`, etc.)
  - `context.df.spacing` — standard spacing tokens (`xs`, `sm`, `md`, `lg`, `xl`, `xxl`)
  - `context.df.shape` — corner radii (`radiusSm`, `radiusMd`, `radiusLg`, `radiusPill`)
  - `context.df.typography` — font styles (`displayLg`, `headingMd`, `bodyMd`, `caption`, etc.)
  - `context.df.motion` — standardized animation durations and curves (`fast`, `normal`, `emphasized`)
  - `context.df.cardShadow` — elevated surface box shadows

---

## Typography & Fonts

`df_theme` deliberately does **not** depend directly on `google_fonts` to avoid dependency conflicts across consuming apps. Fonts are referenced by family name; apps bundle their own font assets or pass a configured `DfTypography` with `TextStyle` definitions.

---

## Component Gallery

To preview all components and themes:

```bash
cd df_theme/example
flutter run -d chrome
```
