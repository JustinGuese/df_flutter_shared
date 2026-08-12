# df_flutter_shared

Shared Flutter packages behind the [DataFortress.cloud](https://datafortress.cloud/) apps —
NaviCare Now, PsychDiary, DocumentChat, TileDom and SocialAnxify.

The split is deliberate: **apps implement their own domain, these packages carry
everything else** — the look, the auth, the plumbing. A new DF app should be able
to pick a brand and start with a working, recognisable shell.

---

## Start here: `df_theme`

`df_theme` is the identity layer. An app defines one `DfBrand` and gets a
complete `ThemeData` for light and dark:

```dart
final brand = DfBrandPresets.dataFortress(
  typography: DfBrandPresets.dataFortressFonts,
  logoAsset: 'assets/images/logo.png',
);

MaterialApp(
  theme: DfTheme.light(brand),
  darkTheme: DfTheme.dark(brand),
  themeMode: ThemeMode.system,
);
```

Widgets then read tokens through `context.df` instead of naming colours:

```dart
Container(
  padding: EdgeInsets.all(context.df.spacing.md),
  decoration: BoxDecoration(
    color: context.df.colors.surface,
    borderRadius: context.df.shape.radiusMd,
    boxShadow: context.df.cardShadow,
  ),
)
```

That indirection is the whole point — one shared widget serves NaviCare's light
navy and TileDom's dark gold without branching on the app.

**See it:** `cd df_theme/example && flutter run -d chrome`. The gallery renders
every themed component under all six brands in both modes, and is how theme
changes get reviewed.

### The house style

`DfBrandPresets.dataFortress` is the default for new apps: warm ink on paper with
a brass fitting, deliberately not the cool Tailwind slate that most product UI
falls into. Fraunces for display, Public Sans for body, JetBrains Mono for
figures. Presets also exist for each shipping app so they can migrate onto
`DfTheme` without changing how they look.

`df_theme` does **not** depend on `google_fonts` — consumers span two
incompatible major versions of it. Fonts are named, not loaded; each app bundles
its own or builds a `TextTheme` with `google_fonts` and passes it in.

---

## Packages

| Package | Description |
|---------|-------------|
| **[df_theme](df_theme/)** | The design system. `DfBrand` (palette + typography + spacing + shape + motion), `DfTokens` `ThemeExtension` with `context.df`, and `DfTheme.light/dark` builders that emit a full `ThemeData` including component sub-themes. Presets for the house style and for every existing app. |
| **[df_ui_widgets](df_ui_widgets/)** | Reusable UI: `QuickActionChip`, `SummaryBulletList`, `KeywordChipList`, `LoadingAppBarAction`, `CharacterCounter`, `BrandedAppBar`, `NumberedStepList`, `SuccessBanner`, `AudioLevelBar`, `RecordingTimer`. |
| **[df_core_utils](df_core_utils/)** | Pure and Flutter utilities: date formatting, keyword/summary parsing, animation durations, cross-platform download helper. |
| **[df_firebase_auth](df_firebase_auth/)** | Firebase Auth and API client: `AuthRepository` (email, Google, Apple), Dio `ApiClient` with bearer-token injection and 401 retry, Riverpod providers, `GoRouterRefreshStream`, and ready-made login/register screens. Override `authConfigProvider`. |
| **[df_firebase_rest](df_firebase_rest/)** | REST implementation of Firebase Auth for platforms the official SDK does not cover (Windows/Linux). Secure token storage and automatic refresh. |
| **[df_api_repository](df_api_repository/)** | `BaseApiRepository` over Dio, with `getList<T>` / `getOne<T>` helpers. Extend it per resource. |
| **[df_chat](df_chat/)** | AI chat backend: `ChatRepository` with configurable endpoints and SSE streaming, Riverpod `ChatController` / `ChatState`, `flutter_chat_types`-compatible models. UI stays in the app. |
| **[df_analytics](df_analytics/)** | Firebase Analytics wrapper, App Tracking Transparency (iOS), Meta (App Events + Pixel), and a consent-first installation flow. `AnalyticsService`, `InstallationTrackingService`, `PrivacyTrackingDialog`. |
| **[df_ai_consent](df_ai_consent/)** | GDPR AI-data consent dialog and SharedPreferences-backed `AiDataConsentService`. App supplies the copy and data items. |
| **[df_onboarding](df_onboarding/)** | Onboarding carousel — configurable pages, completion flag in SharedPreferences, override `onboardingConfigProvider`. |
| **[df_courses](df_courses/)** | Stepped course player with pluggable chapter types (reading, checklist, red flags, quiz), `CourseProgressNotifier`, and optional per-step gating via `stepGateBuilder`. Supersedes the learning-course screens that used to live in `df_onboarding`. |
| **[df_paywall](df_paywall/)** | Subscription paywall UI: `PaywallConfig`, `showPaywallUpsellSheet`, `PaywallUpsellInline` (use as a `stepGateBuilder` result), `PaywallPremiumScreen`. Pure UI — pair with `df_billing` for state. |
| **[df_billing](df_billing/)** | The state layer behind `df_paywall`: `DfSubscriptionStatus`, cached entitlement that survives a backend outage, refresh-on-resume, `dfIsPremiumProvider`, and `DfCheckout` for opening hosted payment links. No Stripe SDK. |
| **[df_notifications](df_notifications/)** | Local reminders: neutral `DfReminder` model, native/web split, reserved id ranges, prefs-backed daily reminder toggle, and a soft-ask permission sheet that runs before the OS prompt. |
| **[df_tour](df_tour/)** | Coach-mark tour harness over `tutorial_coach_mark`: app-declared steps, prefs-backed completion, safe target building, a replay hub sheet and a help button. Step content stays in the app. |
| **[df_feedback_prompt](df_feedback_prompt/)** | One-time feedback dialog on first launch, with configurable copy and callbacks. |
| **[df_speech_to_text](df_speech_to_text/)** | On-device speech-to-text with Riverpod: listening state, permission flow, microphone dialog, record button, cursor-aware `SpeechTextController`. |
| **[df_whisper_speech](df_whisper_speech/)** | Backend Whisper transcription: record, upload, transcribe. Use this instead of `df_speech_to_text` when accuracy matters more than latency and a backend is available. |
| **[df_audio_capture](df_audio_capture/)** | Cross-platform audio recording including system/loopback capture on desktop. Decibel levels, multiple output formats. |
| **[df_device_id](df_device_id/)** | Persistent per-install UUID in `flutter_secure_storage`. |

---

## Using a package

Apps depend on these over git, tracking `main`:

```yaml
dependencies:
  df_theme:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_theme
      ref: main
```

Then override any required providers in `ProviderScope` and import
`package:df_theme/df_theme.dart`. Each package has its own README.

### Working on a package locally

Do **not** edit the `git:` block to a `path:`. Create a `pubspec_overrides.yaml`
next to the app's `pubspec.yaml` — it is gitignored, so it cannot be committed by
accident:

```yaml
dependency_overrides:
  df_theme:
    path: ../df_flutter_shared/df_theme
```

Delete the file (or run `flutter pub get` after removing it) to go back to the
published `main`.

---

## Developing

```bash
./tool/analyze_all.sh            # pub get + analyze every package
./tool/analyze_all.sh df_theme   # just one
```

CI runs the same thing plus `dart format --set-exit-if-changed` and any tests,
and then builds the consuming apps against the branch.

**Every app tracks `main` directly and nothing is version-tagged**, so a merge
here reaches five production apps on their next `pub upgrade`. CI is the only
thing between a bad push and five broken builds — keep it green, and prefer an
additive change over a breaking one.

Conventions:

- Packages should not depend on each other, with one exception: anything visual
  may depend on `df_theme`. The app wires everything else together.
- No hardcoded colours, radii or spacing in a shared widget — read `context.df`.
  A literal hex in this repo is a bug; it bakes one app's brand into all of them.
- No hardcoded user-facing copy in a language. Strings belong in a config object
  with English defaults.
- Every package has its own `analysis_options.yaml`; they are generated copies,
  so change them together.
- Library packages do not commit `pubspec.lock`.
