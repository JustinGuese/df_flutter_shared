/// A coach-mark tour harness on top of `tutorial_coach_mark`.
///
/// Owns the plumbing every hand-rolled app tour re-wrote: a step model, safe
/// `TargetFocus` building from `GlobalKey`s (skipping ones that aren't
/// mounted yet, which `tutorial_coach_mark` otherwise throws on), per-step
/// completion in SharedPreferences, a themed hub sheet for replaying steps,
/// and a help button that opens it. Step content — titles, copy, which
/// widgets to spotlight — is always supplied by the app.
library;

export 'src/tour_coach_marks.dart';
export 'src/tour_help_button.dart';
export 'src/tour_hub_sheet.dart';
export 'src/tour_progress.dart';
export 'src/tour_progress_notifier.dart';
export 'src/tour_step.dart';
export 'src/tour_strings.dart';
export 'src/tour_target.dart';
