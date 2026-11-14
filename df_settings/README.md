# df_settings

Reusable settings scaffold, groups, tiles, legal links, and account deletion for DataFortress apps.

Satisfies Apple App Store and Google Play compliance requirements (e.g. mandatory in-app account deletion, privacy policy, and terms of service access) while following the DataFortress design system (`df_theme` and `df_ui_widgets`).

---

## Features

- **`DfSettingsScaffold`** — Top-level scaffold with theme canvas background and safe-area scroll view.
- **`DfSettingsGroup`** — Visual grouping for settings tiles with optional `DfSectionHeader` and surface card containment.
- **`DfSettingsTile`** — Token-styled list row supporting leading icons, subtitles, and chevron navigation affordances.
- **`DfThemeModeTile`** — Appearance switcher supporting system default, light, and dark modes.
- **`DfLocaleTile`** — Locale / language picker dialog with custom formatter support.
- **`DfLegalLinksSection`** — Ready-to-use legal links (Privacy Policy, Terms of Service, Website, Support Mail, Licenses) with an injectable URL launcher seam.
- **`DfVersionFooter`** — App version, build number, and copyright footer.
- **`DfDeleteAccountTile`** — Destructive account deletion row with mandatory double-check confirmation dialog.
- **`DfSettingsStrings`** — Localized copy with English defaults and German (`DfSettingsStrings.de`) support.

---

## Architecture & Layers

`df_settings` sits at **Layer 3** (L3) of the DataFortress architecture. It depends only on:
- `df_theme` (L0)
- `df_ui_widgets` (L1)

Capability sections (e.g. auth info, subscriptions, push notification toggles) are composed into `DfSettingsScaffold` or `DfSettingsGroup` by consuming applications as children, avoiding horizontal or circular dependencies across L2/L3 packages.

---

## Installation

```yaml
dependencies:
  df_settings:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_settings
      ref: main
```

---

## Usage

```dart
import 'package:df_settings/df_settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DfSettingsScaffold(
      footer: const DfVersionFooter(
        version: '1.0.0',
        buildNumber: '42',
        appName: 'My App',
      ),
      children: [
        DfSettingsGroup(
          title: 'Preferences',
          children: [
            DfThemeModeTile(
              currentMode: ThemeMode.system,
              onModeChanged: (mode) {
                // update app theme
              },
            ),
          ],
        ),
        DfLegalLinksSection(
          privacyPolicyUrl: 'https://example.com/privacy',
          termsOfServiceUrl: 'https://example.com/terms',
          supportEmail: 'support@example.com',
        ),
        DfSettingsGroup(
          card: false,
          children: [
            DfDeleteAccountTile(
              onDeleteAccount: () async {
                // delete account API call
              },
            ),
          ],
        ),
      ],
    );
  }
}
```
