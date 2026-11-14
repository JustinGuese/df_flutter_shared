# PLAN — df_flutter_shared restructure

Rules for every step: ADDITIVE ONLY (apps track `main`; no renames or removals of public symbols, moved code is re-exported from its old location). No hardcoded colours/spacing (read `context.df`), no hardcoded copy (`*Strings` class with English defaults). No `pubspec.lock`. Each new package gets `pubspec.yaml`, `README.md`, `analysis_options.yaml` (copy from a sibling), `lib/<pkg>.dart`, `lib/src/`.
Tests are Flutter (`cd <pkg> && flutter test`), 1-3 per step max: core behaviour, edge cases only.

## Batch 0 — Contracts (written by me, committed before any worker starts)
Contracts only; workers must match these names exactly.
- `df_api`: `class DfApiClient` (same ctor/params as current `ApiClient` in df_firebase_auth), `typedef DfTokenProvider = Future<String?> Function()`, `class DfApiException implements Exception {int? status; String message;}`, `DfApiException mapDioError(Object e)`.
- `df_error_reporting`: `abstract interface class DfErrorSink { void recordError(Object e, StackTrace? s, {String? reason, bool fatal}); void setUser(String? id); void log(String msg); }`, `DfErrorReporting.install(DfErrorSink)` (wires `FlutterError.onError` + `PlatformDispatcher.onError`), `NoopErrorSink`, `RecordingErrorSink` (tests).
- `df_settings`: `DfSettingsScaffold`, `DfSettingsGroup`, `DfSettingsTile`, `DfThemeModeTile`, `DfLocaleTile`, `DfLegalLinksSection`, `DfVersionFooter`, `DfDeleteAccountTile`, `DfSettingsStrings`.
- `df_app_shell`: `sharedPreferencesProvider`, `DfThemeModeController` (prefs-backed Notifier<ThemeMode>), `DfLocaleController`, `DfNavShell` (adaptive bottom-bar/rail), `DfNavDestination`, `DfAppShellStrings`.
- Layers (CI-checked): L0 `df_theme`, `df_analytics_core`, `df_error_reporting`, `df_api`, leaf utils → L1 `df_ui_widgets` → L2 capability packages → L3 `df_funnel`, `df_settings`, `df_app_shell`. A package may only depend on lower layers.

## Batch 1 — Foundations (parallel, disjoint)
- **S1 CI + layer check.** Files: `.github/workflows/ci.yml`, `tool/check_layers.sh`, `tool/analyze_all.sh`. Matrix generated from `df_*` directories (so `df_funnel`, `df_file_download`, new packages are covered). Add consumer apps: socialanxiety, quoteremember, tradingbot, explainer-video. `check_layers.sh` fails on a dependency pointing upward per Batch 0 layers. AC: script passes on the repo after Batch 1.
- **S2 `df_api` extraction.** Files: `df_api/**` (new), `df_firebase_auth/lib/src/api_client.dart`, `df_firebase_auth/lib/df_firebase_auth.dart`, `df_firebase_auth/pubspec.yaml`. Move Dio client + 401 retry + error mapper into `df_api`; `df_firebase_auth` depends on it and re-exports `ApiClient` (typedef/subclass of `DfApiClient`). Test: bearer injected; 401 triggers exactly one token refresh + retry.
- **S3 PromptChain move.** Files: `df_feedback_prompt/lib/**` (new `src/prompt_chain.dart`, barrel), `df_funnel/lib/src/prompt_chain.dart`, `df_funnel/lib/df_funnel.dart`. Move `DfPromptChain`/`DfPrompt`; funnel re-exports. Move/keep existing prompt-chain tests green. AC: `import df_funnel` still exposes both symbols.
- **S4 UI kit additions.** Files: `df_ui_widgets/lib/**`, `df_speech_to_text/lib/src/speech_text_controller.dart`, `df_whisper_speech/lib/src/speech_text_controller.dart`, both speech `pubspec.yaml`. Canonical `SpeechTextController` (the cursor-aware whisper version) in `df_ui_widgets`; both speech packages re-export it. Add `DfSkeleton`/`DfSkeletonList` (shimmer via `context.df.motion`). Test: insertion preserves surrounding text and cursor.
- **S5 `df_error_reporting` (core).** Files: `df_error_reporting/**` (new). Test: `install` routes a thrown framework error to the sink; Noop never throws.

## Batch 2 — Capability packages (parallel; depend on Batch 1)
- **S6 `df_error_reporting_firebase`.** Files: `df_error_reporting_firebase/**`. `firebase_crashlytics` sink implementing `DfErrorSink`. Test: maps `fatal`/`reason`/`setUser` correctly via fake.
- **S7 `df_settings`.** Files: `df_settings/**`. Per Batch 0 contract; depends on `df_theme`, `df_ui_widgets` only (sections from funnel/notifications/auth are passed in by the app as children). Test: legal links open through an injectable launcher; delete-account requires confirmation.
- **S8 `df_app_shell`.** Files: `df_app_shell/**`. Test: theme mode persists and restores; `DfNavShell` switches rail vs bar at the breakpoint.
- **S9 auth hex cleanup.** Files: `df_firebase_auth/lib/src/widgets/{login_screen,register_screen,google_icon}.dart`. Replace literal `Color(0x...)` with `context.df` tokens (keep the Google logo's brand colours as the documented exception, in `google_icon.dart` only). AC: no other literal hex left.

## Batch 3 — German strings (parallel, mechanical)
Each package gains `Strings.de()` named constructor/const next to the English default; no behaviour changes.
- **S10** `df_firebase_auth` (login, register, account settings, sign-in sheet), `df_funnel`, `df_revenuecat`, `df_billing`. Reuse the app-local German account strings from the explainer-video app as source.
- **S11** `df_notifications`, `df_tour`, `df_courses`, `df_ai_consent`, `df_feedback_prompt`, `df_swipe_deck`, `df_ads`. Test (one per group): `.de()` has no empty field.

## Batch 4 — Docs and soft deprecation (parallel)
- **S12 Docs.** Files: `README.md`, `df_billing/README.md`, new `README.md` for `df_theme`, `df_courses`, `df_analytics_core`, `df_feedback_prompt`, `df_api`. Layers section replaces "packages should not depend on each other"; decision-tree rows for settings, shell, error reporting.
- **S13 `df_core_utils` soft retire.** Files: `df_core_utils/lib/**`, `df_ui_widgets/lib/**`. Copy keyword/summary parsers into `df_ui_widgets` (next to their widgets); mark the originals `@Deprecated` pointing at the new home. Do NOT delete or add dependencies.

## Not in this run — need your decision
1. **Delete `df_paywall`**: removal breaks the additive rule, and I couldn't see DocuChat or NaviCare end-user. Safer: confirm they don't import it, then delete in its own PR.
2. **Pub workspace**: needs a spike (does git-consumption still resolve?). Not safe to hand to a worker.
3. **`tiledom-crypto` stale path deps**: lives in another repo.
4. **Tests for `df_theme`, `df_chat`, audio packages, `df_firebase_auth`**: recommended before further `df_firebase_auth` changes; say if you want them as an extra batch.

## Final review (me)
`./tool/analyze_all.sh`, `flutter test` for touched packages, `check_layers.sh`, `git diff pre-agy` against this plan: confirm no re-export was dropped and no config weakened.
