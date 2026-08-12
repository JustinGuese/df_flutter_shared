import 'tour_step.dart';

/// Persisted tour progress: whether the tour has been auto-opened once, and
/// which step ids have been visited.
class TourProgressState {
  const TourProgressState({
    this.seen = false,
    this.visited = const <String>{},
    this.loaded = false,
  });

  /// Whether the tour has already been opened automatically once. Apps that
  /// auto-open the hub on first launch should gate that on `!seen`.
  final bool seen;

  /// Ids of steps the tour has shown ("look" steps). "Do" steps are not
  /// necessarily in here — their completion usually comes from the app's own
  /// data via `isDoneOverride`, see [TourProgress.isDone].
  final Set<String> visited;

  /// Whether SharedPreferences has been read yet. Before this is true, [seen]
  /// reads as `false` regardless of what's actually stored — callers that
  /// auto-open the tour on `!seen` must also check [loaded], or every user
  /// (including ones who dismissed the tour long ago) sees it flash open on
  /// each cold start.
  final bool loaded;

  TourProgressState copyWith({
    bool? seen,
    Set<String>? visited,
    bool? loaded,
  }) => TourProgressState(
    seen: seen ?? this.seen,
    visited: visited ?? this.visited,
    loaded: loaded ?? this.loaded,
  );
}

/// Resolves a step's completion, optionally overridden by app data.
///
/// Return `null` to fall back to "was it visited"; return `true`/`false` to
/// override — this is how a "do" step (e.g. "create your first profile") gets
/// its done state from real app data instead of from whether the tour showed
/// it, so a user who did it outside the tour still sees it checked off.
typedef TourStepDoneResolver = bool? Function(TourStep step);

/// Pure helpers over a step list + visited set. No Flutter or persistence
/// dependency, so these are trivial to unit test.
abstract final class TourProgress {
  static bool isDone(
    TourStep step,
    Set<String> visited, {
    TourStepDoneResolver? isDoneOverride,
  }) {
    final overridden = isDoneOverride?.call(step);
    if (overridden != null) return overridden;
    return visited.contains(step.id);
  }

  /// How many of [steps] are complete.
  static int doneCount(
    List<TourStep> steps,
    Set<String> visited, {
    TourStepDoneResolver? isDoneOverride,
  }) => steps
      .where((s) => isDone(s, visited, isDoneOverride: isDoneOverride))
      .length;

  /// Steps not yet complete, in declaration order.
  static List<TourStep> remaining(
    List<TourStep> steps,
    Set<String> visited, {
    TourStepDoneResolver? isDoneOverride,
  }) => steps
      .where((s) => !isDone(s, visited, isDoneOverride: isDoneOverride))
      .toList();

  /// The first incomplete step — where the hub should jump to. `null` once
  /// everything is done.
  static TourStep? nextStep(
    List<TourStep> steps,
    Set<String> visited, {
    TourStepDoneResolver? isDoneOverride,
  }) {
    for (final step in steps) {
      if (!isDone(step, visited, isDoneOverride: isDoneOverride)) return step;
    }
    return null;
  }
}
