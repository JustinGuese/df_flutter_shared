# Local Flutter packages

Reusable Flutter packages used by PsychDiary and other apps from [DataFortress.cloud](https://datafortress.cloud/). Add them to your app via path dependencies (e.g. `path: ../packages/df_speech_to_text`).

---

## Packages

| Package | Description |
|---------|-------------|
| **[df_ai_consent](df_ai_consent/)** | GDPR-compliant AI data consent dialog and service: configurable `AiDataConsentDialog` (names Google Gemini and DataFortress Cloud, links to privacy policy), `AiDataConsentService` (SharedPreferences-backed consent state), and `AiConsentConfig` / `AiConsentDataItem` for app-specific copy and data items. Each app creates its own service instance with a unique prefs key and wraps the dialog with app-specific content. |
| **[df_speech_to_text](df_speech_to_text/)** | Speech-to-text with Riverpod: notifier for listening state and recognized text, permission flow, configurable microphone dialog, and a record button widget. Use `SpeechTextController` to insert text into a `TextEditingController` at the cursor. Optional analytics callback when listening starts. |
| **[df_analytics](df_analytics/)** | Analytics and installation tracking: Firebase Analytics wrapper, App Tracking Transparency (iOS), Meta (Facebook App Events + Meta Pixel), and a consent-first installation flow. Provides `AnalyticsService`, `InstallationTrackingService`, and `PrivacyTrackingDialog`; app defines event names via extensions. |
| **[df_firebase_auth](df_firebase_auth/)** | Firebase Auth and API client: `AuthRepository` (email, Google, Apple), Dio-based `ApiClient` with Bearer token injection, Riverpod auth providers, and ready-made login/register screens. App overrides `authConfigProvider` with API URL, server client ID, logo, app name, and routes. |
| **[df_firebase_rest](df_firebase_rest/)** | Generic REST implementation of Firebase Auth: `FirebaseRestAuth` and `FirebaseRestUser` for platforms not supported by the official SDK (Windows/Linux). Supports sign-in, sign-up, secure token storage, and automatic refresh. |
| **[df_audio_capture](df_audio_capture/)** | Generic cross-platform audio recording: Supports microphone and system/loopback audio capture across Windows, Linux, macOS, Android, iOS, and Web. Handles decibel levels and multiple output formats. |
| **[df_device_id](df_device_id/)** | Persistent device identification: Generates a unique UUID and stores it securely using `flutter_secure_storage` to identify unique installations. |
| **[df_onboarding](df_onboarding/)** | Onboarding carousel: configurable pages (icon, title, subtitle, features, gradient, emoji), completion flag in SharedPreferences, and callbacks for post-onboarding actions (e.g. tracking consent, navigation). App overrides `onboardingConfigProvider` with page list and preferences key; uses `OnboardingWrapper` and `OnboardingScreen`. |
| **[df_chat](df_chat/)** | AI chat backend: `ChatRepository` with configurable endpoints and SSE streaming, Riverpod `ChatController` / `ChatState`, and `flutter_chat_types`-compatible models. App overrides `chatRepositoryProvider` with a `ChatRepository(Dio)` instance; wire `onMessageSent` on the controller for analytics. UI (screens, quick actions) stays in the app. |
| **[df_api_repository](df_api_repository/)** | Base repository for Dio-based APIs: `BaseApiRepository` holds `Dio` and optional `ApiRepositoryConfig` (default page size, timeouts). Helpers `getList<T>` and `getOne<T>` for paginated lists and single resources. Extend in your app (e.g. `DiaryRepository extends BaseApiRepository`) and implement endpoint-specific methods. |
| **[df_ui_widgets](df_ui_widgets/)** | Reusable UI: `QuickActionChip` (optional gradient/colors), `SummaryBulletList` (bullets, "+X more", optional title/icon), `KeywordChipList` (tags + AI pulse indicator), `LoadingAppBarAction`, `CharacterCounter` (live char count), `BrandedAppBar` (gradient AppBar, optional logo asset), `NumberedStepList` (step-by-step instruction list), `SuccessBanner` (confirmation banner with optional warning pill). Theme-based defaults; pass app colors/gradients for branding. |
| **[df_core_utils](df_core_utils/)** | Pure and Flutter utilities: date formatting (`dateOnly`, `formatEntryDate`, `formatGermanDate`, `formatGermanDateTime`, `formatGermanEntryDate`), keyword/summary parsing (`parseKeywords`, `keywordsFromController`, `parseSummaryPoints`), animation durations (`AnimationDurations`: fast, normal, medium, slow, pulse, emphasis), cross-platform download helper. No app-specific types. |

---

## Using a package

1. Add a path dependency in your appâ€™s `pubspec.yaml`:

   ```yaml
   dependencies:
     df_speech_to_text:
       path: ../packages/df_speech_to_text
   ```

2. Run `flutter pub get` in the app.
3. Override any required providers in `ProviderScope` (see each packageâ€™s README).
4. Import and use the package: `import 'package:df_speech_to_text/df_speech_to_text.dart';`

Each package has its own **README.md** with installation, configuration, usage, and API details.

---

## Developing packages

From the repo root (or the app that uses them):

- Run `flutter pub get` in each package directory after changing `pubspec.yaml`.
- Run `flutter analyze` in each package and in the app after code changes.
- Packages do not depend on each other; the app wires them (e.g. onboarding calls analytics for consent).


