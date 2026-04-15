# df_onboarding

Reusable onboarding and learning course system for Flutter apps. Two independent feature sets in one package:

1. **Onboarding carousel** — configurable welcome screens with completion tracking
2. **Learning course viewer** — step-based course UI with progress tracking and optional step gating (e.g. paywalls)

Used by [DataFortress.cloud](https://datafortress.cloud/) apps.

---

## Installation

```yaml
dependencies:
  df_onboarding:
    path: ../df_onboarding  # or git source
```

```dart
import 'package:df_onboarding/df_onboarding.dart';
```

---

## Feature 1 — Onboarding Carousel

### Setup

Override `onboardingConfigProvider` in your `ProviderScope`:

```dart
ProviderScope(
  overrides: [
    onboardingConfigProvider.overrideWithValue(OnboardingConfig(
      prefsKey: 'my_app_onboarding_v1',
      pages: [
        OnboardingPageModel(
          emoji: '🩺',
          title: 'Welcome',
          subtitle: 'Your health companion',
          gradient: [Color(0xFF0E6B82), Color(0xFF0C445A)],
        ),
      ],
      onComplete: () => ref.read(analyticsProvider).trackOnboarding(),
    )),
  ],
  child: MyApp(),
)
```

### Usage

```dart
// Wrap your root widget — automatically shows onboarding on first launch
OnboardingWrapper(child: MyApp())

// Or navigate directly
Navigator.push(context, MaterialPageRoute(builder: (_) => OnboardingScreen()))
```

### Key classes
| Class | Purpose |
|-------|---------|
| `OnboardingConfig` | Page list, prefs key, callbacks |
| `OnboardingPageModel` | Single page: emoji, title, subtitle, gradient, features list |
| `onboardingConfigProvider` | Override this in ProviderScope |
| `OnboardingWrapper` | Auto-shows onboarding on first launch |
| `OnboardingScreen` | The full carousel screen |

---

## Feature 2 — Learning Course Viewer

A full-screen stepped course player. Each course has up to 4 sections:
- **sofortUmsetzbar** — interactive checkbox list (persisted progress)
- **beiRisiko** — read-only professional steps
- **warnsignale** — warning signs + inline quick-check
- **notfall** — emergency actions + CTA button

Progress is persisted to SharedPreferences and can be synced to a backend.

### Minimal usage

```dart
LearningCourseScreen(
  course: LearningCourseModel(
    key: 'sturzrisiko',
    emoji: '🦶',
    title: 'Sturzrisiko',
    subtitle: 'Sofortmaßnahmen & Prävention',
    gradient: [Color(0xFF0E6B82), Color(0xFF0C445A)],
    riskLevelLabel: 'Hohes Risiko',
    riskLevelColor: Colors.red,
    steps: [...],  // List<LearningStepModel>
  ),
  onFirstOpen: () => backend.recordOpen('sturzrisiko'),
  onProgressChanged: (completedIds) => backend.sync('sturzrisiko', completedIds),
)
```

### Step gating (paywall)

Pass `stepGateBuilder` to block navigation to specific steps. Return a widget to show in place of the step content, or `null` to allow navigation:

```dart
LearningCourseScreen(
  course: course,
  stepGateBuilder: (stepIndex) {
    if (stepIndex == 0 || isPremium) return null;  // step 0 always free
    return PaywallUpsellInline(                     // from df_paywall
      stepTitle: course.steps[stepIndex].title,
      stepEmoji: course.steps[stepIndex].emoji,
      config: myPaywallConfig,
      onCta: () => checkoutService.start(),
    );
  },
)
```

When the gate is active, the bottom nav shows a "Zurück" button to dismiss it. Step dot navigation is also restricted.

### Progress tracking

```dart
// Read progress anywhere
final progress = ref.watch(learningProgressNotifierProvider);
final completedIds = progress['sturzrisiko']; // Set<String>

// Merge backend progress (call once per course open)
ref.read(learningProgressNotifierProvider.notifier)
   .mergeFromBackend('sturzrisiko', backendIds);
```

Item ID format: `{courseKey}_{sectionType}_{index}` (e.g. `sturzrisiko_sofortUmsetzbar_2`)

### Key classes
| Class | Purpose |
|-------|---------|
| `LearningCourseModel` | Course metadata + steps list |
| `LearningStepModel` | Single step: type, emoji, title, items[], optional CTA |
| `CourseSectionType` | `sofortUmsetzbar`, `beiRisiko`, `warnsignale`, `notfall` |
| `LearningCourseScreen` | Full-screen course viewer widget |
| `LearningCourseCard` | Summary card for course listing screens |
| `LearningProgressNotifier` | Riverpod notifier, SharedPreferences-backed |
| `learningProgressNotifierProvider` | Watch/read progress state |
