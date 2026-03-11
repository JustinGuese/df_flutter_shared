# df_ai_consent

GDPR-compliant AI data consent dialog and service for Flutter apps that process user data via Google Gemini (through DataFortress Cloud).

Satisfies Apple App Store guidelines 5.1.1(i) and 5.1.2(i) by requiring explicit user consent before any AI processing occurs.

---

## Features

- `AiDataConsentService` — SharedPreferences-backed consent state; one instance per app with a unique prefs key
- `AiConsentConfig` / `AiConsentDataItem` — data classes for all app-specific copy (intro text, data items, processor text, privacy URL)
- `AiDataConsentDialog` — non-dismissible modal dialog; `showIfNeeded` only shows once per install (skips if already consented)

---

## Installation

```yaml
dependencies:
  df_ai_consent:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_ai_consent
      ref: main
```

---

## Usage

### 1. Create a thin wrapper in your app

`lib/widgets/ai_data_consent_dialog.dart`:

```dart
import 'package:df_ai_consent/df_ai_consent.dart' as pkg;
import 'package:flutter/material.dart';

final _consentService = pkg.AiDataConsentService(
  consentKey: 'myapp_ai_data_consent_given',
);

const _consentConfig = pkg.AiConsentConfig(
  introText: 'MyApp uses AI to … To provide this service, the following data is processed:',
  dataItems: [
    pkg.AiConsentDataItem(
      icon: Icons.description_outlined,
      title: 'Document content',
      description: 'Text from your documents is sent for AI analysis.',
    ),
  ],
  processorText:
      'Your data is routed through DataFortress Cloud (DataFortress GmbH, Germany) '
      'on GDPR-compliant German servers. The underlying AI processing is performed '
      'by Google Gemini (Google LLC, USA).',
  privacyPolicyUrl: 'https://myapp.com/privacy-policy/',
);

class AiDataConsentDialog {
  static Future<bool> showIfNeeded(BuildContext context) =>
      pkg.AiDataConsentDialog.showIfNeeded(
        context,
        service: _consentService,
        config: _consentConfig,
      );
}
```

### 2. Gate AI actions behind consent

```dart
final consented = await AiDataConsentDialog.showIfNeeded(context);
if (!consented) return; // user declined — skip AI processing
```

### 3. Revoke consent (e.g. in settings)

```dart
await _consentService.revokeConsent();
```

---

## API

### `AiDataConsentService`

| Member | Description |
|--------|-------------|
| `AiDataConsentService({required String consentKey})` | Constructor — use a unique key per app |
| `Future<bool> hasConsented()` | Returns stored consent value (cached after first read) |
| `Future<void> grantConsent()` | Persists `true` and updates cache |
| `Future<void> revokeConsent()` | Persists `false` and updates cache |

### `AiConsentConfig`

| Field | Type | Description |
|-------|------|-------------|
| `introText` | `String` | Paragraph shown at the top of the dialog |
| `dataItems` | `List<AiConsentDataItem>` | Data items listed in the dialog body |
| `processorText` | `String` | Text in the highlighted processor box |
| `privacyPolicyUrl` | `String` | URL opened when user taps "Privacy Policy" |

### `AiConsentDataItem`

| Field | Type | Description |
|-------|------|-------------|
| `icon` | `IconData` | Leading icon |
| `title` | `String` | Bold item title |
| `description` | `String` | Item description |

### `AiDataConsentDialog.showIfNeeded`

```dart
static Future<bool> showIfNeeded(
  BuildContext context, {
  required AiDataConsentService service,
  required AiConsentConfig config,
})
```

Returns `true` if the user consents (or already had consented). Returns `false` if the user declines or the context is unmounted.
