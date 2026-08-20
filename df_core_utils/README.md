# df_core_utils

Reusable Dart/Flutter utilities: date formatting, keyword and summary parsing, and animation duration constants. No app-specific types. Used by [DataFortress.cloud](https://datafortress.cloud/) apps (e.g. PsychDiary, DocumentChat).

This package is deliberately **plugin-free** — it adds no permissions, no native code and no platform channels to a consuming app. Please keep it that way when adding utilities.

---

## Contents

| Module | Exports | Description |
|--------|---------|-------------|
| **date_utils** | `dateOnly`, `formatEntryDate`, `formatGermanDate`, `formatGermanDateTime`, `formatGermanEntryDate` | Strip time from `DateTime`; English diary format; German short date (`dd.MM.yyyy`), datetime (`dd.MM.yyyy HH:mm`), and long weekday (`Dienstag, 15. April 2025`). |
| **keyword_utils** | `parseKeywords`, `keywordsFromController` | Comma-separated keyword string → list; extract keywords from a `TextEditingController`. |
| **summary_utils** | `parseSummaryPoints` | Multi-line summary string → list of bullet points (handles •, -, *, numbered lines). |
| **animation_constants** | `AnimationDurations` | Static durations: `fast`, `normal`, `medium`, `slow`, `pulse`, `emphasis`. |

> **Moved:** `downloadFile` now lives in [`df_file_download`](../df_file_download). It depended on `open_filex`, whose manifest injects `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` into every app that transitively depended on this package — which got PsychDiary rejected from Google Play under the Photo and Video Permissions policy in August 2026. If you need it, add `df_file_download` explicitly and read its README before shipping.

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
   ```

---

## Dependencies

- `flutter` (SDK), `intl` (for date formatting).

No platform plugins, and therefore no permissions added to consuming apps.
