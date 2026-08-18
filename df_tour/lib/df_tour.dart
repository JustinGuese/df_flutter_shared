/// A coach-mark tour harness on top of `tutorial_coach_mark`.
///
/// Owns the plumbing every hand-rolled app tour re-wrote: a step model, safe
/// `TargetFocus` building from `GlobalKey`s (skipping ones that aren't
/// mounted yet, which `tutorial_coach_mark` otherwise throws on), per-step
/// completion in SharedPreferences, a themed hub sheet for replaying steps,
/// and a help button that opens it. Step content — titles, copy, which
/// widgets to spotlight — is always supplied by the app.
library;

// `TourTarget.align` is typed `ContentAlign`, so it is part of this package's
// public API whether or not it originates here. Without this re-export every
// consumer has to add a direct `tutorial_coach_mark` dependency just to say
// which side a bubble sits on — which defeats the point of wrapping it, and
// pins apps to this package's transitive version.
export 'package:tutorial_coach_mark/tutorial_coach_mark.dart'
    show ContentAlign;

export 'src/tour_coach_marks.dart';
export 'src/tour_help_button.dart';
export 'src/tour_hub_sheet.dart';
export 'src/tour_progress.dart';
export 'src/tour_progress_notifier.dart';
export 'src/tour_step.dart';
export 'src/tour_strings.dart';
export 'src/tour_target.dart';
