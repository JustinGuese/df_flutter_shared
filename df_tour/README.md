# df_tour

A coach-mark tour harness on top of [`tutorial_coach_mark`](https://pub.dev/packages/tutorial_coach_mark).

NaviCare and TileDom each hand-rolled the same plumbing around
`tutorial_coach_mark`: a step model, a filter that skips `GlobalKey`s that
aren't mounted yet (the package throws otherwise), per-step completion in
SharedPreferences, a "replay a step" hub sheet, and a help button that opens
it. This package is that plumbing, generalised. It owns the **harness**, not
the **content** — every title, body and target key is supplied by the app
that uses it.

## What's in it

- **`TourStep`** — a plain class (not an enum) identifying one step of an
  app's tour: `id`, `title`, `body` (the "why"), optional `emoji`/`ctaLabel`,
  and `isDoStep` for steps whose completion should come from real app data
  rather than "was it shown".
- **`TourTarget`** — one spotlight within a step: a `GlobalKey`, bubble
  `title`/`body`, alignment and shape.
- **`buildTourTargetFocus` / `showTourCoachMarks`** — build a safe
  `TargetFocus` list (skipping unmounted keys) and show the overlay, themed
  via `df_theme` tokens.
- **`tourProgressProvider`** (Riverpod) — persists which steps have been
  visited and whether the tour has been auto-opened once, to
  SharedPreferences.
- **`TourProgress`** — pure helpers (`isDone`, `doneCount`, `remaining`,
  `nextStep`) over a step list + visited set, with an optional per-step
  override for "do" steps.
- **`TourHubSheet`** — a themed bottom sheet listing every step, the next
  incomplete one expanded with its "why" and a CTA, done steps replayable.
- **`TourHelpButton`** — a "?" button that opens the hub, with a dot while
  steps remain.
- **`DfTourStrings`** — all copy, English defaults, overridable for
  localization.

Nothing in this package names a colour, radius or spacing value directly —
every visual comes from `context.df` (`df_theme`), so the same hub sheet and
bubble read correctly in any app's brand.

## What's *not* in it

Deliberately out of scope, because it's app content or app wiring, not
harness:

- The steps themselves (titles, copy, which widgets to spotlight) — always
  app-declared.
- Navigation between steps (pushing a route, opening a dialog) — the app
  supplies an `onStartStep` callback; this package has no router dependency.
- Detecting "this screen should show its tour now" (e.g. a `?tour=1` query
  param plus a post-frame retry loop) — that's coupled to whichever router
  (or none) the app uses, so it stays in the app.

## Install

```yaml
dependencies:
  df_tour:
    path: ../df_tour
```

## Usage

Declare your steps once, as `const` values:

```dart
import 'package:df_tour/df_tour.dart';

const kProfileStep = TourStep(
  id: 'profile',
  title: 'Create your profile',
  body: 'Everything else in the app hangs off a profile — without one, '
      'the rest stays empty.',
  emoji: '👤',
  ctaLabel: 'Create profile',
  isDoStep: true, // done once real data exists, not just once shown
);

const kTopicsStep = TourStep(
  id: 'topics',
  title: 'Your topics',
  body: 'Topics are generated from your profile, so you always know '
      'where to start.',
  emoji: '🎓',
);

const kTourSteps = [kProfileStep, kTopicsStep];
```

On the screen for a step, attach `GlobalKey`s to the widgets worth
spotlighting and show them after the first frame:

```dart
final _topicsListKey = GlobalKey();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final shown = showTourCoachMarks(
      context,
      targets: [
        TourTarget(
          key: _topicsListKey,
          title: 'Your topics',
          body: 'Generated from your profile — the traffic-light shows '
              'where to start.',
        ),
      ],
      onFinish: () =>
          ref.read(tourProgressProvider.notifier).markVisited(kTopicsStep),
    );
    // `shown` is false if the key wasn't mounted yet (e.g. still loading) —
    // retry on the next frame instead of marking the step done.
  });
}
```

Wire up the hub and help button — typically the help button sits in your
dashboard header, and `onStartStep` decides what "start this step" means for
your app (push a route, open a dialog, ...):

```dart
TourHelpButton(
  steps: kTourSteps,
  onStartStep: (context, step) async {
    switch (step.id) {
      case 'profile':
        await showDialog<void>(context: context, builder: (_) => const ProfileDialog());
      case 'topics':
        context.push('/topics?tour=1');
    }
  },
  // "do" steps resolve against real data instead of "was it visited".
  isDoneOverride: (step) =>
      step.id == 'profile' ? ref.read(hasProfileProvider) : null,
)
```

`TourHubSheet.show(context, ref, steps: ..., onStartStep: ...)` opens the same
sheet directly (e.g. to auto-open it on first launch, gated on
`!ref.watch(tourProgressProvider).seen`).

## Dependencies

`flutter_riverpod`, `shared_preferences`, `tutorial_coach_mark`, `df_theme`.
