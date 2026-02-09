# df_core_utils

Reusable Dart/Flutter utilities: date formatting, keyword and summary parsing, and animation duration constants. No app-specific types. Used by [DataFortress.cloud](https://datafortress.cloud/) apps (e.g. PsychDiary).

---

## Contents

| Module | Exports | Description |
|--------|---------|-------------|
| **date_utils** | `dateOnly`, `formatEntryDate` | Strip time from `DateTime`; format as “EEEE, MMMM d, y” (intl). |
| **keyword_utils** | `parseKeywords`, `keywordsFromController` | Comma-separated keyword string → list; extract keywords from a `TextEditingController`. |
| **summary_utils** | `parseSummaryPoints` | Multi-line summary string → list of bullet points (handles •, -, *, numbered lines). |
| **animation_constants** | `AnimationDurations` | Static durations: `fast`, `normal`, `medium`, `slow`, `pulse`, `emphasis`. |

---

## Setup

1. Add a path dependency:

   ```yaml
   dependencies:
     df_core_utils:
       path: ../packages/df_core_utils
   ```

2. Import and use:

   ```dart
   import 'package:df_core_utils/df_core_utils.dart';

   final date = dateOnly(DateTime.now());
   final formatted = formatEntryDate(date);
   final keywords = parseKeywords('happy, calm, exercise');
   final points = parseSummaryPoints(aiSummaryText);
   // AnimationDurations.normal, etc.
   ```

---

## Dependencies

- `flutter` (SDK), `intl` (for date formatting).
