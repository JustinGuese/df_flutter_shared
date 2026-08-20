# df_file_download

Cross-platform "hand these bytes to the user as a file" helper. On web it triggers a browser download; on mobile/desktop it writes the bytes to the temp directory and opens them with the platform handler.

Split out of `df_core_utils` so that packages needing only date/keyword/summary helpers do not inherit this package's Android permissions — see [Android permissions](#android-permissions).

---

## Contents

| Module | Exports | Description |
|--------|---------|-------------|
| **download_helper** | `downloadFile` | `Future<void> downloadFile(Uint8List bytes, String fileName)` — browser download on web, temp file + platform handler elsewhere. |

---

## Setup

```yaml
dependencies:
  df_file_download:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_file_download
      ref: main
```

```dart
import 'package:df_file_download/df_file_download.dart';

await downloadFile(bytes, 'report.pdf');
```

---

## Android permissions

`open_filex` declares these in its own manifest, and Android's manifest merger unions them into **every** app that ends up with this package in its dependency graph:

- `READ_MEDIA_IMAGES`
- `READ_MEDIA_VIDEO`
- `READ_MEDIA_AUDIO`
- `READ_EXTERNAL_STORAGE` (`maxSdkVersion="32"`)

**Google Play rejects apps that declare these without a matching photo/video feature** under the [Photo and Video Permissions policy](https://support.google.com/googleplay/android-developer/answer/14115180). This happened to PsychDiary in August 2026, purely because `df_core_utils` depended on `open_filex` — the app has no photo feature and never called `downloadFile`.

Two rules follow:

1. **Only depend on this package if the app actually hands files to the user.** Needing `dateOnly` is not a reason to pull in media permissions; depend on `df_core_utils` instead.
2. **Even when you do depend on it, strip the permissions** unless the app genuinely reads the user's photo library. `downloadFile` never needs them: it opens a file it just wrote into the app's own temp directory, which `open_filex` hands to the system via `FileProvider`. The media-read permissions are only required to open files owned by *other* apps.

   Add to the app's `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" tools:node="remove" />
   <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" tools:node="remove" />
   <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" tools:node="remove" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" tools:node="remove" />
   ```

   (The `<manifest>` element needs `xmlns:tools="http://schemas.android.com/tools"`.)

Always verify against the **merged** manifest, not the app's source manifest — the permissions are invisible in the latter:

```
build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml
```

---

## Dependencies

- `flutter` (SDK), `web` (browser download path).
- `open_filex`, `path_provider` (mobile/desktop path).
