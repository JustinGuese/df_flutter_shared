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
| **[df_swipe_deck](df_swipe_deck/)** | Tinder-like card swiping deck (`DfSwipeDeck`), action bar (`DfSwipeActionBar`), hint (`DfSwipeHint`), progress bar (`DfDeckProgressBar`), and item interleaving (`interleaveEvery`). |
| **[df_ads](df_ads/)** | Google Mobile Ads wrapper: test/release unit IDs (`DfAdUnitIds`), pluggable `DfAdFactory`, banner slots, card ads, and interstitial cadence control. |
| **[df_revenuecat](df_revenuecat/)** | RevenueCat subscriptions & paywall launcher: config, trial offer helpers, paywall launcher with analytics tracking and exit offers, and customer info streams. |
| **[df_ads_revenuecat](df_ads_revenuecat/)** | Bridge adapter (`DfRevenueCatAdFactory`) connecting `df_ads` and RevenueCat AdMob ad tracking. |
| **[df_theme](df_theme/)** | The design system. `DfBrand` (palette + typography + spacing + shape + motion), `DfTokens` `ThemeExtension` with `context.df`, and `DfTheme.light/dark` builders that emit a full `ThemeData` including component sub-themes. Presets for the house style and for every existing app. |
| **[df_ui_widgets](df_ui_widgets/)** | Reusable UI: `DfFilterChipBar`, `DfTypingIndicator`, `QuickActionChip`, `SummaryBulletList`, `KeywordChipList`, `LoadingAppBarAction`, `CharacterCounter`, `BrandedAppBar`, `NumberedStepList`, `SuccessBanner`, `AudioLevelBar`, `RecordingTimer`, `ScrollHint`. |
| **[df_core_utils](df_core_utils/)** | Pure and Flutter utilities: date formatting, keyword/summary parsing, animation durations, cross-platform download helper. |
| **[df_firebase_auth](df_firebase_auth/)** | Firebase Auth and API client: `AuthRepository` (email, Google, Apple), Dio `ApiClient` with bearer-token injection and 401 retry, Riverpod providers, `GoRouterRefreshStream`, and ready-made login/register screens. Override `authConfigProvider`. |
| **[df_firebase_rest](df_firebase_rest/)** | REST implementation of Firebase Auth for platforms the official SDK does not cover (Windows/Linux). Secure token storage and automatic refresh. |
| **[df_api_repository](df_api_repository/)** | `BaseApiRepository` over Dio, with `getList<T>` / `getOne<T>` helpers. Extend it per resource. |
| **[df_chat](df_chat/)** | AI chat backend: `ChatRepository` with configurable endpoints and SSE streaming, Riverpod `ChatController` / `ChatState`, `flutter_chat_types`-compatible models. UI stays in the app. |
| **[df_analytics_core](df_analytics_core/)** | The analytics contract, with no SDKs: `DfAnalyticsCore.track/screenView/identify` (fail-soft, GA4-validated), the `DfAnalyticsSink` interface, the shared funnel vocabulary (`DfEvents`), `DfScreenObserver` for routers and a `RecordingAnalyticsSink` for tests. `df_onboarding`, `df_firebase_auth`, `df_ai_consent` and `df_tour` report through it, so every app gets onboarding / sign-in / consent / tour events without wiring. |
| **[df_analytics](df_analytics/)** | Firebase Analytics wrapper, App Tracking Transparency (iOS), Meta (App Events + Pixel), and a consent-first installation flow. `AnalyticsService.initialize(metaConversions:, sendUserId:)` installs `DfFirebaseMetaSink` — every event to GA4, only mapped conversions to Meta (`sign_up` → CompleteRegistration by default). `InstallationTrackingService`, `PrivacyTrackingDialog`. |
| **[df_ai_consent](df_ai_consent/)** | GDPR AI-data consent dialog and SharedPreferences-backed `AiDataConsentService`. App supplies the copy and data items. |
| **[df_onboarding](df_onboarding/)** | Onboarding carousel — configurable pages, completion flag in SharedPreferences, override `onboardingConfigProvider`. |
| **[df_funnel](df_funnel/)** | Cohesive launch funnel (`DfLaunchGate`), unified premium state (`dfEffectivePremiumProvider`), lock widgets (`DfPremiumGate`), upsell sheets (`DfUpsellSheet`), prompt chains (`DfPromptChain`), and subscription settings (`DfSubscriptionSettingsSection`). Supersedes `df_paywall`. |
| **[df_courses](df_courses/)** | Stepped course player with pluggable chapter types (reading, checklist, red flags, quiz), `CourseProgressNotifier`, and optional per-step gating via `stepGateBuilder`. Supersedes the learning-course screens that used to live in `df_onboarding`. |
| **[df_paywall](df_paywall/)** *(deprecated)* | **Deprecated** — use **[df_funnel](df_funnel/)**. Legacy subscription paywall UI (`PaywallConfig`, `showPaywallUpsellSheet`, `PaywallUpsellInline`, `PaywallPremiumScreen`). |
| **[df_billing](df_billing/)** | The state layer behind `df_paywall`: `DfSubscriptionStatus`, cached entitlement that survives a backend outage, refresh-on-resume, `dfIsPremiumProvider`, and `DfCheckout` for opening hosted payment links. No Stripe SDK. |
| **[df_notifications](df_notifications/)** | Local reminders & scheduling: neutral `DfReminder` model, native/web split, reserved id ranges, daily reminder controller (`DfDailyReminder`), trial ending reminder (`DfTrialEndingReminder`), settings toggle tile (`DfNotificationToggleTile`), and soft-ask permission sheet (`ensureDfNotificationPermission`). |
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

---

## For LLMs / agents working in this repo

When contributing to `df_flutter_shared` or working in consumer apps that depend on it, follow these rules and architectural patterns:

### The "Check this repo first" rule

**Before writing app-local UI, plumbing, auth, or billing logic in any consumer app, check `df_flutter_shared` first.**
If a shared component, service, or provider exists, consume it. If a generic feature is being built for an app that other DataFortress apps will need, extract it into this repo rather than creating app-local copies.

### Decision Tree: Which package to use?

| Need | Recommended Package & API | Notes |
|------|---------------------------|-------|
| **Onboarding** | **`df_funnel`** (`DfLaunchGate`, `DfFunnelStep.onboarding`) + **`df_onboarding`** (`OnboardingCarousel`, `onboardingConfigProvider`) | `DfLaunchGate` sequences onboarding before home, tracking completion via SharedPreferences. |
| **Paywall** | **`df_funnel`** (`DfLaunchGate` paywall step, `DfUpsellSheet`, or `requirePremium()`) backed by **`df_revenuecat`** (`DfPaywallLauncher`) | **`df_paywall` is deprecated** — do not use `df_paywall` in new code. |
| **Login / Auth** | **`df_funnel`** (`DfLaunchGate`, `DfFunnelStep.login`) + **`df_firebase_auth`** (`AuthRepository`, `currentUserProvider`, `LoginScreen`) or **`df_firebase_rest`** (REST for Windows/Linux) | Governed by `DfLoginMode` (`required`, `optional`, or `deferred`). |
| **Premium Lock** | **`df_funnel`** (`DfPremiumGate`, `requirePremium()`) | Wraps UI widgets with a lock overlay that launches the paywall and automatically unlocks upon purchase. |
| **Effective Premium State** | **`df_funnel`** (`dfEffectivePremiumProvider`, `dfAuthRevenueCatSyncProvider`) | Unifies RevenueCat Pro and backend subscriptions (`dfIsPremiumProvider`) into a single reactive boolean. Syncs auth changes with RevenueCat. |
| **In-App Prompt Chain** | **`df_funnel`** (`DfPromptChain`, `DfPrompt`) + **`df_feedback_prompt`** (`DfCooldown`, `DfPromptScheduler`) | Priority-ordered interruption queue spaced by event counts and persistent cooldowns. |
| **Notifications** | **`df_notifications`** (`DfDailyReminder`, `DfTrialEndingReminder`, `DfNotificationToggleTile`, `ensureDfNotificationPermission`, `DfReminderService`) | Neutral reminder models, idempotent daily controllers, trial expiration alerts, and pre-prompt priming sheets. |
| **Settings Screen** | **`df_funnel`** (`DfSubscriptionSettingsSection`) + **`df_notifications`** (`DfNotificationToggleTile`) | Ready-made sections for App Store / Google Play subscription management, Customer Center, purchase restore, and push notification toggles. |
| **UI Widgets** | **`df_ui_widgets`** (`DfFilterChipBar`, `DfTypingIndicator`, `QuickActionChip`, `SummaryBulletList`, `BrandedAppBar`, `NumberedStepList`, `SuccessBanner`, etc.) | Domain-agnostic components fully styled with `context.df` tokens. |
| **Theming & Design** | **`df_theme`** (`DfTheme`, `DfBrand`, `context.df`) | Unified token system for palettes, spacing, typography, shape, and motion. |

### The Funnel Order

The standard launch sequence enforced by `DfLaunchGate` is:
```
onboarding  ──>  paywall  ──>  login  ──>  home
```
1. **`onboarding`**: Introduces product value and walkthrough carousel before asking for commitments.
2. **`paywall`**: Presents subscription offerings while engagement is high. Automatically skipped if the user is already premium (`entitlementReader`). Skippable by the user (`Maybe Later`).
3. **`login`**: Authenticates or recovers account state. Behaviors via `DfLoginMode`:
   - `required`: Blocks navigation until signed in.
   - `optional`: Shows sign-in screen with a "Skip for now" option.
   - `deferred`: Bypasses launch-time login entirely; auth is requested on demand when accessing gated features.

### Core Conventions

1. **No hard-coded copy**:
   - User-facing text must never be hard-coded inside a widget or service.
   - Supply strings via a dedicated `*Strings` class (e.g. `DfNotificationStrings`, `DfSubscriptionSettingsStrings`, `DfTypingIndicatorStrings`, `DfDailyReminderStrings`, `CourseStrings`) with sensible English defaults.
2. **No hard-coded colours, spacing, or radii**:
   - Always read styling tokens through `context.df` (e.g. `context.df.colors.brand.base`, `context.df.spacing.md`, `context.df.shape.radiusMd`).
   - Literal hex colours, manual corner radii, or fixed margins break multi-brand consistency across apps.
3. **Additive changes only**:
   - Five or more production apps track `main` directly.
   - Never break, rename, or drop existing public constructors, methods, or parameters. Introduce new features additively with optional parameters and backwards-compatible defaults.
4. **Git dependencies tracking `main`**:
   - Consuming apps reference packages in `pubspec.yaml` via:
     ```yaml
     dependencies:
       df_funnel:
         git:
           url: https://github.com/JustinGuese/df_flutter_shared.git
           path: df_funnel
           ref: main
     ```
5. **Use `pubspec_overrides.yaml` for local development**:
   - When developing across repos, create `pubspec_overrides.yaml` in the app's root with `dependency_overrides`.
   - Never commit `path:` references directly into the app's `pubspec.yaml`.
6. **Push before apps can consume**:
   - Apps fetch shared code from GitHub `main`. Pushing to this repo is required before consumer CI or apps can resolve new shared APIs.

### How to Add a New Package or Test

1. **Adding a package**:
   - Create a subfolder: `<package_name>/`.
   - Include `pubspec.yaml`, `README.md`, standard `analysis_options.yaml` (copied from adjacent packages), `lib/<package_name>.dart`, and `lib/src/`.
   - If visual, depend on `df_theme` and build with `context.df`.
   - Do not commit `pubspec.lock`.
2. **Writing and running tests**:
   - Place unit/widget tests in `<package_name>/test/`.
   - Run tests:
     ```bash
     cd <package_name> && flutter test
     ```
3. **Validating analysis**:
   - Run the shared analysis script from the repo root:
     ```bash
     ./tool/analyze_all.sh <package_name>   # test one package
     ./tool/analyze_all.sh                 # test all packages
     ```
