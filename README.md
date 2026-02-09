# Local Flutter packages

Reusable Flutter packages used by PsychDiary and other apps from [DataFortress.cloud](https://datafortress.cloud/). Add them to your app via path dependencies (e.g. `path: ../packages/df_speech_to_text`).

---

## Packages

| Package | Description |
|---------|-------------|
| **[df_speech_to_text](df_speech_to_text/)** | Speech-to-text with Riverpod: notifier for listening state and recognized text, permission flow, configurable microphone dialog, and a record button widget. Use `SpeechTextController` to insert text into a `TextEditingController` at the cursor. Optional analytics callback when listening starts. |
| **[df_analytics](df_analytics/)** | Analytics and installation tracking: Firebase Analytics wrapper, App Tracking Transparency (iOS), Meta (Facebook App Events + Meta Pixel), and a consent-first installation flow. Provides `AnalyticsService`, `InstallationTrackingService`, and `PrivacyTrackingDialog`; app defines event names via extensions. |
| **[df_firebase_auth](df_firebase_auth/)** | Firebase Auth and API client: `AuthRepository` (email, Google, Apple), Dio-based `ApiClient` with Bearer token injection, Riverpod auth providers, and ready-made login/register screens. App overrides `authConfigProvider` with API URL, server client ID, logo, app name, and routes. |
| **[df_onboarding](df_onboarding/)** | Onboarding carousel: configurable pages (icon, title, subtitle, features, gradient, emoji), completion flag in SharedPreferences, and callbacks for post-onboarding actions (e.g. tracking consent, navigation). App overrides `onboardingConfigProvider` with page list and preferences key; uses `OnboardingWrapper` and `OnboardingScreen`. |
| **[df_chat](df_chat/)** | AI chat backend: `ChatRepository` with configurable endpoints and SSE streaming, Riverpod `ChatController` / `ChatState`, and `flutter_chat_types`-compatible models. App overrides `chatRepositoryProvider` with a `ChatRepository(Dio)` instance; wire `onMessageSent` on the controller for analytics. UI (screens, quick actions) stays in the app. |
| **[df_api_repository](df_api_repository/)** | Base repository for Dio-based APIs: `BaseApiRepository` holds `Dio` and optional `ApiRepositoryConfig` (default page size, timeouts). Helpers `getList<T>` and `getOne<T>` for paginated lists and single resources. Extend in your app (e.g. `DiaryRepository extends BaseApiRepository`) and implement endpoint-specific methods. |
| **[df_ui_widgets](df_ui_widgets/)** | Reusable UI: `QuickActionChip` (optional gradient/colors), `SummaryBulletList` (bullets, “+X more”, optional title/icon), `KeywordChipList` (tags + AI pulse indicator), `LoadingAppBarAction`. Theme-based defaults; pass app colors/gradients for branding. |
| **[df_core_utils](df_core_utils/)** | Pure and Flutter utilities: `dateOnly` / `formatEntryDate` (intl), `parseKeywords` / `keywordsFromController`, `parseSummaryPoints`, `AnimationDurations` (fast, normal, pulse, etc.). No app-specific types. |

---

## Using a package

1. Add a path dependency in your app’s `pubspec.yaml`:

   ```yaml
   dependencies:
     df_speech_to_text:
       path: ../packages/df_speech_to_text
   ```

2. Run `flutter pub get` in the app.
3. Override any required providers in `ProviderScope` (see each package’s README).
4. Import and use the package: `import 'package:df_speech_to_text/df_speech_to_text.dart';`

Each package has its own **README.md** with installation, configuration, usage, and API details.

---

## Developing packages

From the repo root (or the app that uses them):

- Run `flutter pub get` in each package directory after changing `pubspec.yaml`.
- Run `flutter analyze` in each package and in the app after code changes.
- Packages do not depend on each other; the app wires them (e.g. onboarding calls analytics for consent).
