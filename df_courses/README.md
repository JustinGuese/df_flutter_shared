# df_courses

Stepped course player with pluggable chapter types and persistent progress tracking for [DataFortress.cloud](https://datafortress.cloud/) apps.

Supersedes the legacy learning-course screens previously bundled inside `df_onboarding`.

Part of Layer 2 (L2) in the `df_flutter_shared` architecture.

---

## Installation

```yaml
dependencies:
  df_courses:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_courses
      ref: main
```

---

## Features

- **Stepped chapter navigation**: One chapter per page with header progress bar, Back/Next controls, and completion celebration.
- **Pluggable chapter types**:
  - `ReadingChapter`: Rich Markdown content, takeaways, and callout tips.
  - `ChecklistChapter`: Interactive checklist items with persistent checkmarks.
  - `RedFlagsChapter`: Warning indicators and high-risk signals with danger badges.
  - `QuizChapter`: Single-choice questions with answer validation and pass requirements.
- **Progress persistence (`CourseProgressNotifier`)**: Automatically saves progress (checked items, passed quizzes, completion timestamps) to `SharedPreferences` with backend merging and legacy ID migration support.
- **Paywall / feature gating (`stepGateBuilder`)**: Intercept navigation to specific chapters to require premium subscription or completion of prerequisites.
- **Multi-language copy (`CourseStrings`)**: English defaults and ready-to-use German (`CourseStrings.de()`) strings.

---

## Usage

### 1. Define a Course

Courses can be parsed from JSON or created in code:

```dart
final course = CourseModel(
  id: 'anxiety_basics',
  title: 'Managing Everyday Anxiety',
  chapters: [
    ReadingChapter(
      id: 'ch1',
      title: 'Understanding Anxiety',
      emoji: '🧠',
      visibleFor: CourseChapterVisibility.any,
      markdownContent: 'Anxiety is your body’s natural response to stress...',
      takeaways: const ['Anxiety is normal', 'Breathing helps regulate heart rate'],
    ),
    ChecklistChapter(
      id: 'ch2',
      title: 'Action Steps',
      emoji: '✅',
      visibleFor: CourseChapterVisibility.any,
      items: const [
        ChecklistItem(id: 'box_breathing', title: 'Try 4-4-4 box breathing'),
        ChecklistItem(id: 'journal_trigger', title: 'Write down what triggered you'),
      ],
    ),
    QuizChapter(
      id: 'ch3',
      title: 'Quick Check',
      emoji: '🎯',
      visibleFor: CourseChapterVisibility.any,
      questions: const [
        QuizQuestion(
          id: 'q1',
          question: 'What is the purpose of box breathing?',
          options: ['To raise heart rate', 'To activate the parasympathetic system'],
          correctOptionIndex: 1,
        ),
      ],
    ),
  ],
);
```

### 2. Display with `CourseScreen`

```dart
CourseScreen(
  course: course,
  tier: CourseRiskTier.low,
  riskLevelLabel: 'Low Risk',
  riskLevelColor: Colors.green,
  stepGateBuilder: (chapterIndex) {
    // Optionally gate chapters beyond the first for free users:
    if (chapterIndex > 0 && !isPremium) {
      return const PremiumGateUpsell();
    }
    return null;
  },
  strings: CourseStrings.de(), // Or default English CourseStrings()
  onProgressChanged: (completedIds) {
    print('Completed items: $completedIds');
  },
)
```
