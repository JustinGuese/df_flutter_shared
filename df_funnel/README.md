# df_funnel

Cohesive onboarding, paywall, and auth funnel with unified premium state for Flutter apps.

`df_funnel` coordinates the user journey from first launch to conversion:
- **Launch gate (`DfLaunchGate`)**: Sequences onboarding carousel, paywall presentation, and sign-in gates before reaching the app home.
- **Unified premium state (`dfEffectivePremiumProvider`)**: Unifies RevenueCat Pro and backend subscriptions into a single source of truth.
- **Auth & RevenueCat sync (`dfAuthRevenueCatSyncProvider`)**: Automatically identifies users, restores purchases on sign-in, and resets state on sign-out.
- **Lock UI & Upsell components**: `DfPremiumGate`, `requirePremium()`, `DfProPill`, `DfProHeroCard`, and `DfUpsellSheet` (with cooldown support).
- **Prompt interruption chain (`DfPromptChain`)**: Priority-ordered in-app interruptions spaced by event counts and cooldowns.

Supersedes `df_paywall`.

---

## Installation

```yaml
dependencies:
  df_funnel:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_funnel
      ref: main
```

```dart
import 'package:df_funnel/df_funnel.dart';
```

---

## 1. Launch Gate (`DfLaunchGate`)

Wrap your main application or home route with `DfLaunchGate` to handle first-run onboarding, paywall, and login before displaying the home content.

```dart
DfLaunchGate(
  config: const DfFunnelConfig(
    steps: [
      DfFunnelStep.onboarding,
      DfFunnelStep.paywall,
      DfFunnelStep.login,
    ],
    loginMode: DfLoginMode.deferred,
    paywallPlacement: 'launch_gate',
  ),
  onboardingBuilder: (context, onComplete) => OnboardingScreen(onComplete: onComplete),
  homeBuilder: (context) => const HomeScreen(),
)
```

### Steps & Login Modes

#### `DfFunnelStep`
- `onboarding`: First-launch walkthrough or carousel.
- `paywall`: Subscription offering screen (automatically skipped if user is already premium).
- `login`: User authentication / account recovery.

#### `DfLoginMode`
- `required`: Blocks navigation until the user successfully logs in.
- `optional`: Shows a sign-in screen with an explicit skip option.
- `deferred`: Skips sign-in during launch; auth is requested on demand when accessing gated features.

---

## 2. Unified Premium State & Auth Sync

### `dfEffectivePremiumProvider`
Combines RevenueCat Pro and backend subscriptions:
- Unlocked if **RevenueCat reports Pro** (anonymous or authenticated)
- OR user is **signed in AND app backend subscription reports premium**
- If signed out, backend subscription status is ignored and returns `false`.

```dart
final isPremium = ref.watch(dfEffectivePremiumProvider);
```

### `dfAuthRevenueCatSyncProvider`
Listens to Firebase Auth state changes:
- **On sign-in**: identifies user via `DfRevenueCat.logIn(uid)`, restores purchases if not pro, invalidates subscription cache, and executes `onSynced`.
- **On sign-out**: calls `DfRevenueCat.logOut()`, clears subscription cache, and resets debug overrides.

```dart
// In your root widget or app initialization:
ref.watch(dfAuthRevenueCatSyncProvider(
  onSynced: () async {
    await ref.read(userSyncProvider).syncUserData();
  },
));
```

---

## 3. Premium Lock UI & Gating

### `DfPremiumGate`
Wraps premium content with a lock overlay when the user is not entitled. Tapping the overlay opens the paywall and automatically unlocks upon successful purchase.

```dart
DfPremiumGate(
  placement: 'ai_analysis',
  child: const AdvancedAnalyticsWidget(),
)
```

### `requirePremium`
Imperative helper for buttons or actions requiring an active subscription. Shows the paywall if the user is not entitled and returns `true` if access is granted.

```dart
final unlocked = await requirePremium(context, ref, 'export_pdf');
if (unlocked) {
  exportPdf();
}
```

### Pro Widgets
- **`DfProPill`**: Compact pill badge indicating premium features.
- **`DfProHeroCard`**: Hero card showcasing Pro features with an upgrade CTA button.
- **`DfUpsellSheet`**: Modal bottom sheet with built-in cooldown (`DfCooldown`) to prevent showing too frequently.

---

## 4. Prompt Interruption Chain (`DfPromptChain`)

Evaluate priority-ordered interruptions (such as review prompts, upsell sheets, or surveys) triggered by event milestones:

```dart
final chain = DfPromptChain(
  [
    DfPrompt(
      id: 'rating_prompt',
      priority: 100,
      minEvents: 5,
      cooldown: DfCooldown(const Duration(days: 30), key: 'cd_rating'),
      show: (context) => showRatingDialog(context!),
    ),
    DfPrompt(
      id: 'upsell_prompt',
      priority: 50,
      minEvents: 3,
      cooldown: DfCooldown(const Duration(days: 7), key: 'cd_upsell'),
      show: (context) => showUpsellDialog(context!),
    ),
  ],
  minEventsBetween: 3,
);

// Call when an event occurs (e.g. user completes an action):
await chain.run(completedEventsCount, context: context);
```
