# PLAN.md (gembuild): df_funnel + unified premium state


## Adaptations to the gembuild recipe (please confirm)
- **Two repos.** Batches 0-2 run in `/home/jguese/code/df_flutter_shared`. Batch 3 runs in `/home/jguese/code/flutter-bigtechnews-swiper-app`. Each gets its own checkpoint branch `agy/work`, worktrees under its own `.git/agy-wt`, and a merge into its own `main`. The shared repo merges first, because bigtechnews tracks its `main`.
- **Tests are Flutter, not pytest.** Each step writes at most 2-3 `flutter test` files covering core behaviour and edge cases. It runs only those, with no `flutter analyze` and no full suite.
- **Checkpoint.** `git add -A` would commit the untracked `DIRECTORIES.md` and `OFFER.md` in bigtechnews. I will stage tracked changes only (`git add -u`) with `--allow-empty`, unless you say otherwise.
- **Final merge to main without asking** is kept, as in the recipe.
- Scope is the funnel and premium state only (plan sections 1-3). The "other modules" list (4.1-4.8) is out of scope for this run.

## Batch 0 (contracts, one step, sequential)
**S0 - analytics events + premium contract** (repo: df_flutter_shared)
- Files: `df_analytics_core/lib/src/df_event_names.dart`, `df_revenuecat/lib/src/paywall_launcher.dart`, `df_funnel/pubspec.yaml`, `df_funnel/lib/df_funnel.dart`, `df_funnel/lib/src/contracts.dart`, `df_funnel/README.md`.
- Do: add `DfEvents.paywallOpened` and `DfEvents.paywallResult`, and use them instead of the raw strings in the launcher. Scaffold the `df_funnel` package (deps: flutter_riverpod, shared_preferences, df_theme, df_analytics_core, df_onboarding, df_revenuecat, df_billing, df_firebase_auth). Define the contracts: `DfFunnelStep` enum (onboarding, paywall, login), `DfLoginMode` (required, optional, deferred), `DfFunnelConfig`, and `DfPaywallPresenter`/`DfEntitlementReader` typedefs for the callback seams. Add `df_funnel` to the README package table and `tool/analyze_all.sh` if it enumerates packages.
- Accept: package resolves with `flutter pub get`, the exports compile, and the launcher emits the constants. One test checks that the event constants equal the old string values, so dashboards are unchanged.

## Batch 1 (parallel, disjoint files)
**S1 - effective premium + auth/RC sync** (df_funnel)
- Files: `df_funnel/lib/src/premium_providers.dart`, `df_funnel/test/premium_providers_test.dart`.
- Do: `dfEffectivePremiumProvider` = RevenueCat pro OR (signed in AND backend premium). `dfAuthRevenueCatSyncProvider` does `logIn(uid)` on sign-in, restores if not pro, invalidates `dfSubscriptionProvider`, and calls `logOut` on sign-out. It takes an `onSynced` callback.
- Accept: tests cover the OR logic (including signed-out with backend premium = false), sync on sign-in and sign-out, and `onSynced` firing once.

**S2 - launch gate** (df_funnel)
- Files: `df_funnel/lib/src/launch_gate.dart`, `df_funnel/lib/src/funnel_state.dart`, `df_funnel/test/launch_gate_test.dart`.
- Do: `DfLaunchGate` runs onboarding, then paywall (skippable, skipped if already pro), then login (by `DfLoginMode`: required blocks, optional shows a skippable screen, deferred skips), then `homeBuilder`. Each step persists its own done flag and emits `DfEvents.tutorialBegin/Complete`. Add a spinner while the flags load.
- Accept: tests cover the fresh-install order, the already-pro paywall skip, the paywall skip path, each login mode, and a resume after a partial flow.

**S3 - premium gate + lock widgets** (df_funnel)
- Files: `df_funnel/lib/src/premium_gate.dart`, `df_funnel/lib/src/pro_widgets.dart` (`DfProPill`, `DfProHeroCard`, `DfUpsellSheet` with cooldown), `df_funnel/test/premium_gate_test.dart`.
- Do: `DfPremiumGate({child, lockedBuilder?, placement})` shows the child if entitled, otherwise a lock overlay. A tap opens the paywall and re-checks on return. `requirePremium(context, ref, placement)` returns a bool. Use `DfCooldown` for the sheet cooldown. Use `df_theme` tokens and a `DfFunnelStrings` class, with no hard-coded colours or copy.
- Accept: tests cover the entitled child, the locked tap opening the paywall once, unlock after purchase, `requirePremium` true/false, and the sheet cooldown.

**S4 - prompt chain** (df_funnel)
- Files: `df_funnel/lib/src/prompt_chain.dart`, `df_funnel/test/prompt_chain_test.dart`.
- Do: `DfPromptChain([DfPrompt])` runs priority-ordered interruptions after an event count, with at most one shown per reservation, using `DfPromptScheduler` and `DfCooldown` from `df_feedback_prompt`.
- Accept: tests cover priority order, one prompt per event, and a cooldown blocking a repeat.

**S5 - docs and deprecation** (repo-wide, docs only)
- Files: `df_onboarding/README.md`, `df_paywall/README.md`, `df_paywall/lib/df_paywall.dart` (add `@Deprecated` on the exports pointing to `df_funnel`), `README.md`.
- Do: fix the stale onboarding README (`OnboardingWrapper(onAlreadyCompleted)`), mark `df_paywall` deprecated, and document `df_funnel` usage.
- Accept: no API changes, and the deprecation annotations compile. No tests.

## Batch 2 (shared repo final, sequential)
Merge Batch 1, run all new tests once, and run `tool/analyze_all.sh` once myself (not by agy). Then merge `agy/work` to `main` in df_flutter_shared and push. bigtechnews cannot see it until it is pushed.

## Batch 3 (bigtechnews, parallel after Batch 2)
**S6 - launch gate + billing**
- Files: `lib/main.dart`, `lib/screens/onboarding_screen.dart`, `lib/billing/app_billing.dart`, `lib/providers/news_provider.dart`, `pubspec.yaml`.
- Do: replace `_LaunchGate` with `DfLaunchGate` (login `deferred`, onboarding then paywall with `placement: 'onboarding'`). Replace `isPremiumProvider` and `authSubscriptionSyncProvider` with the shared providers, passing `onSynced: syncLikes`. Switch the custom onboarding events to `DfEvents`. Add `df_funnel` and remove the unused `df_paywall`, `df_device_id`, `df_core_utils` and `df_api_repository`.
- Accept: 1-2 widget tests that the first launch shows onboarding and then the paywall step, and that a second launch goes straight home.

**S7 - lock widgets + prompts**
- Files: `lib/widgets/pro_pill.dart` (delete), `lib/widgets/pro_hero_card.dart` (delete), `lib/billing/pro_upsell_sheet.dart` (delete), `lib/billing/ask_ai_launcher.dart`, `lib/providers/prompt_scheduler.dart` (delete), `lib/screens/home/feed_prompts.dart`, `lib/screens/chat/chat_locked_view.dart`.
- Do: use the df_funnel widgets, `requirePremium` and `DfPromptChain`. Callers of the deleted files get fixed within these files only. Anything outside the list is flagged for me, not edited.
- Accept: 1-2 tests that a locked tap opens the paywall and that an entitled tap runs the action.

**S8 - settings auth block**
- Files: `lib/screens/settings_screen.dart`, `lib/screens/auth/save_progress_sheet.dart`.
- Do: adopt `DfAccountSettingsSection` and `DfSignInSheet`, keeping the delete flow (`DELETE /api/v1/user`, `deleteAccount`, `signOut`, `DfRevenueCat.logOut`). Switch the hard-coded `Colors.*` to `context.df` tokens.
- Accept: 1 test that the delete flow calls the backend, then sign-out, then RevenueCat logout, in that order.

## Final review (me)
Run each repo's new tests once, run `git diff pre-agy` against this plan, and check that no config or test was weakened. Manual device check of the fresh-install funnel is left to you.

## Report
Pass/fail per step, in under 5 lines.
