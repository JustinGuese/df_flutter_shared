# CLAUDE.md

Guidelines for LLMs and developers working in `df_flutter_shared` or consuming apps.

## Key Principles & Conventions

1. **Check this repo first**:
   - Before building app-local UI, plumbing, auth, notifications, or billing logic in consumer apps, check if a shared solution exists here. Extract domain-agnostic code into this repo.
2. **Funnel architecture (`df_funnel`)**:
   - The canonical launch order is `onboarding` ──> `paywall` ──> `login` via `DfLaunchGate`.
   - Gate features using `DfPremiumGate` and `requirePremium()`, which read `dfEffectivePremiumProvider` (combining RevenueCat Pro + backend subscriptions).
   - Use `DfPromptChain` for priority-ordered, cooldown-spaced in-app interruptions.
   - **`df_paywall` is deprecated** — always use `df_funnel`.
3. **Theming (`df_theme`)**:
   - Never hardcode colours, radii, or spacing in shared widgets. Read tokens via `context.df`.
4. **Strings & Localization**:
   - Never hardcode user-facing strings. Provide a `*Strings` class with English defaults (e.g., `DfNotificationStrings`, `DfSubscriptionSettingsStrings`, `DfTypingIndicatorStrings`).
5. **Additive changes only**:
   - Consuming apps track `main` directly. Do not introduce breaking changes or rename public symbols. Add optional parameters with sensible defaults.
6. **Package consumption & local dev**:
   - Consuming apps reference packages via git tracking `ref: main`.
   - Use `pubspec_overrides.yaml` with `dependency_overrides` for local multi-repo development — never commit `path:` dependencies to app `pubspec.yaml`.
   - Push changes to `df_flutter_shared` before consuming apps can resolve them on CI.
7. **Testing & Analysis**:
   - Analyze: `./tool/analyze_all.sh` (or `./tool/analyze_all.sh <package_name>`)
   - Test: `cd <package_name> && flutter test`
   - Never commit `pubspec.lock` in library packages.

For the complete decision tree, package table, and architectural documentation, refer to [README.md](README.md).
