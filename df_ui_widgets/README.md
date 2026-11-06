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
| **DfFilterChipBar** | Horizontally scrollable row of selectable filter chips/pills with haptic feedback, customizable labels, and trailing action slot. Built on `context.df`. |
| **DfTypingIndicator** | Bot-style message bubble with pulsing dots and optional label (defaults to "Thinking…"). Animates smoothly and respects reduced motion settings. |
| **AudioLevelBar** | Real-time audio waveform/level visualizer bar for microphone recording. |
| **RecordingTimer** | Formatted elapsed timer display (`MM:SS`) for audio capture. |
| **ScrollHint** | Subtle animated hint indicating more scrollable content is available below or beside the viewport. |

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

## Detailed Components

### `DfFilterChipBar<T>`

A horizontally scrollable row of selectable filter chips/pills, generalised from app feed filter bars. Highlights the selected item with brand colors and triggers haptic feedback on tap.

#### Signature
```dart
class DfFilterChipBar<T> extends StatelessWidget {
  const DfFilterChipBar({
    super.key,
    required this.items,
    this.selected,
    required this.onSelected,
    this.labelBuilder,
    this.trailing,
    this.height = 56.0,
    this.padding,
    this.spacing,
    this.enableHapticFeedback = true,
  });
}
```

#### Usage
```dart
enum ArticleCategory { all, tech, science, business }

ArticleCategory selectedCategory = ArticleCategory.all;

DfFilterChipBar<ArticleCategory>(
  items: ArticleCategory.values,
  selected: selectedCategory,
  labelBuilder: (category) => switch (category) {
    ArticleCategory.all => 'All',
    ArticleCategory.tech => 'Technology',
    ArticleCategory.science => 'Science',
    ArticleCategory.business => 'Business',
  },
  onSelected: (category) {
    setState(() => selectedCategory = category);
  },
  trailing: IconButton(
    icon: const Icon(Icons.tune),
    onPressed: () => showFilterBottomSheet(context),
  ),
)
```

---

### `DfTypingIndicator`

An animated bot-style bubble with pulsing dots and optional text label, shown while waiting for an AI streaming response or chat partner. Automatically respects `MediaQuery.disableAnimationsOf(context)` for accessibility.

#### Signature
```dart
class DfTypingIndicator extends StatefulWidget {
  const DfTypingIndicator({
    super.key,
    this.label,
    this.strings = const DfTypingIndicatorStrings(),
    this.dotColor,
    this.backgroundColor,
    this.textStyle,
    this.alignment = Alignment.centerLeft,
    this.dotCount = 3,
    this.dotSize = 8.0,
    this.dotSpacing = 4.0,
    this.duration = const Duration(milliseconds: 1200),
    this.padding,
    this.margin,
    this.borderRadius,
  });
}
```

#### Usage
```dart
// Standard AI thinking bubble (shows 3 pulsing dots + "Thinking…"):
const DfTypingIndicator()

// Dots only without text label:
const DfTypingIndicator(label: '')

// Localized or customized copy:
const DfTypingIndicator(
  strings: DfTypingIndicatorStrings(label: 'Generating response…'),
)
```

---

## Dependencies

- `flutter` only.
