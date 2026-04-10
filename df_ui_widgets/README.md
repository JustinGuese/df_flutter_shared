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
| **CharacterCounter** | Live character count display for a `TextEditingController`. Shows `current/max`; turns error color when over limit. Optional `style` override. |
| **BrandedAppBar** | Gradient `AppBar` using `colorScheme.primary → secondary`. Optional `logoAsset` path; when null, shows title only. Gradient and icon colors are theme-based. |
| **NumberedStepList** | Vertical list of numbered steps (circle badge + title + description). Optional `numberColor`; defaults to `theme.colorScheme.primary`. |
| **SuccessBanner** | Confirmation banner: icon, title, body, optional warning note. Pass `color` for branding (e.g. green); defaults to `Colors.green`. |

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
