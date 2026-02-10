# df_core_utils

Reusable Dart/Flutter utilities: date formatting, keyword and summary parsing, animation duration constants, and a cross-platform download helper. No app-specific types. Used by [DataFortress.cloud](https://datafortress.cloud/) apps (e.g. PsychDiary, DocumentChat).

---

## Contents

| Module | Exports | Description |
|--------|---------|-------------|
| **date_utils** | `dateOnly`, `formatEntryDate` | Strip time from `DateTime`; format as “EEEE, MMMM d, y” (intl). |
| **keyword_utils** | `parseKeywords`, `keywordsFromController` | Comma-separated keyword string → list; extract keywords from a `TextEditingController`. |
| **summary_utils** | `parseSummaryPoints` | Multi-line summary string → list of bullet points (handles •, -, *, numbered lines). |
| **animation_constants** | `AnimationDurations` | Static durations: `fast`, `normal`, `medium`, `slow`, `pulse`, `emphasis`. |
| **download_helper** | `downloadFile` | Cross-platform file download helper (web + mobile/desktop). |

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

   // Dates & text
   final date = dateOnly(DateTime.now());
   final formatted = formatEntryDate(date);
   final keywords = parseKeywords('happy, calm, exercise');
   final points = parseSummaryPoints(aiSummaryText);

   // Animation durations
   final duration = AnimationDurations.normal;

   // Cross-platform downloads:
   // - Web: triggers browser download
   // - Mobile/desktop: saves to temp and opens with platform handler
   Future<void> saveBytes(Uint8List bytes, String name) async {
     await downloadFile(bytes, name);
   }
   ```

---

## Dependencies

- `flutter` (SDK), `intl` (for date formatting).
- `open_filex`, `path_provider` (for the download helper on mobile/desktop).
