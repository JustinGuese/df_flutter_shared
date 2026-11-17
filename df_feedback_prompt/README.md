# df_feedback_prompt

Feedback prompt dialogs, store review prompts, cooldown trackers, and priority-ordered prompt interruption chains for [DataFortress.cloud](https://datafortress.cloud/) apps.

Part of Layer 2 (L2) in the `df_flutter_shared` architecture.

---

## Installation

```yaml
dependencies:
  df_feedback_prompt:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_feedback_prompt
      ref: main
```

---

## Key Components

- **`FeedbackPromptListener`**: Wraps the home route or subtree to display a friendly, one-time feedback prompt dialog on first launch, configured via `FeedbackPromptConfig`.
- **`DfPromptChain` & `DfPrompt`**: Priority-ordered queue for app interruptions (upsells, ratings, feature tours). Evaluates eligibility based on priorities, min-event thresholds, predicates, and persistent cooldowns.
- **`DfPromptScheduler`**: Spacing coordinator ensuring that only one prompt shows at a time and that a minimum number of user actions or events elapse before another prompt may trigger.
- **`DfCooldown`**: Persistent cooldown timer backed by `SharedPreferences` to throttle prompts (e.g. at most once every 14 days).
- **`DfStoreReviewPrompt`**: Automated store rating prompt utilizing `in_app_review`, gated by minimum positive action streaks and cooldown intervals.

---

## Usage

### 1. One-Time Feedback Dialog

Wrap your home screen with `FeedbackPromptListener`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:df_feedback_prompt/df_feedback_prompt.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeedbackPromptListener(
      child: Scaffold(
        body: Center(child: Text('Home Content')),
      ),
    );
  }
}
```

Configure strings and email destination by overriding `feedbackPromptConfigProvider`:

```dart
ProviderScope(
  overrides: [
    feedbackPromptConfigProvider.overrideWithValue(
      const FeedbackPromptConfig(
        feedbackEmail: 'support@datafortress.cloud',
        title: 'Enjoying the app?',
      ),
    ),
  ],
  child: const MyApp(),
);
```

### 2. Prompt Interruption Chain (`DfPromptChain`)

Coordinate multiple candidate interruptions (upsells, rating requests, tours) with priorities and spacing:

```dart
final chain = DfPromptChain(
  scheduler: ref.read(dfPromptSchedulerProvider.notifier),
  prompts: [
    // High priority: Paywall upsell on 3rd meaningful event
    DfPrompt(
      id: 'paywall_prompt',
      priority: 10,
      minEvents: 3,
      cooldown: DfCooldown(
        preferencesKey: 'paywall_prompt_cooldown',
        cooldown: const Duration(days: 7),
      ),
      show: (context) async {
        await DfUpsellSheet.show(context!);
        return true;
      },
    ),
    // Medium priority: App Store review
    DfPrompt(
      id: 'store_review',
      priority: 5,
      minEvents: 5,
      cooldown: DfCooldown(
        preferencesKey: 'store_review_cooldown',
        cooldown: const Duration(days: 30),
      ),
      show: (context) async {
        return DfStoreReviewPrompt.requestReview();
      },
    ),
  ],
);

// Trigger on meaningful user action:
await chain.evaluate(context, eventCount: currentActions);
```

### 3. Persistent Cooldown (`DfCooldown`)

```dart
final cooldown = DfCooldown(
  preferencesKey: 'my_feature_cooldown',
  cooldown: const Duration(days: 14),
);

if (await cooldown.isReady()) {
  // Present prompt or offer...
  await cooldown.mark();
}
```
