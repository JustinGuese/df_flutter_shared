# df_ui_widgets

Reusable Flutter UI widgets with optional theme/color parameters so the package stays app-agnostic. Used by [DataFortress.cloud](https://datafortress.cloud/) apps (e.g. PsychDiary). Pass your app’s gradients and colors for branding, or rely on theme defaults.

---

## Widgets

| Widget | Description |
|--------|-------------|
| **QuickActionChip** | Rounded chip with icon + label. Optional `gradient`, `iconColor`, `labelColor`; when null, uses `theme.colorScheme.primary` / `onPrimary`. Supports `compact` and `onPressed`. |
| **SummaryBulletList** | Bullet list with optional `title`, `icon`, `maxVisible` (“+X more”), `emptyStateText`, `isLoading`. Optional `titleIconGradient`, `titleColor`, `bulletColor` for branding. |
| **KeywordChipList** | Title + list of keyword chips; optional `icon`, colors, `emptyStateText`. When `isLoading`, shows an “Analyzing with AI…” pulse indicator. |
| **LoadingAppBarAction** | Small circular progress indicator for AppBar actions (e.g. saving). |

---

## Setup

1. Add a path dependency:

   ```yaml
   dependencies:
     df_ui_widgets:
       path: ../packages/df_ui_widgets
   ```

2. Import and use:

   ```dart
   import 'package:df_ui_widgets/df_ui_widgets.dart';

   QuickActionChip(
     icon: Icons.add,
     label: 'New Entry',
     gradient: AppGradients.primary,
     iconColor: AppColors.onPrimary,
     labelColor: AppColors.onPrimary,
     onPressed: () => ...,
   )

   SummaryBulletList(
     title: 'Summary',
     icon: Icons.format_list_bulleted,
     points: summaryPoints,
     titleIconGradient: AppGradients.primary,
   )
   ```

If you don’t pass gradient/colors, widgets fall back to `Theme.of(context).colorScheme`.

---

## Dependencies

- `flutter` only.
