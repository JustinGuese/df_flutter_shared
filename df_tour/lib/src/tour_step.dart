import 'package:flutter/foundation.dart';

/// One entry in an app's guided tour, declared by the app.
///
/// A plain class rather than an enum: an enum would force every app that
/// wants to add or reorder a step to edit a shared type in this package.
/// Apps build a `List<TourStep>` (usually a `const` list of top-level
/// constants) and pass it to [TourHubSheet], [TourHelpButton] and the
/// [TourProgress] helpers.
///
/// A [TourStep] only carries the step's identity and hub copy. The widgets to
/// spotlight for a step live on whichever screen shows them, built as
/// [TourTarget]s and passed to `showTourCoachMarks` at the point the step is
/// actually shown — a step can span a screen that isn't mounted yet (or isn't
/// mounted at all, e.g. behind a paywall), so it cannot carry live
/// [GlobalKey]s of its own.
@immutable
class TourStep {
  const TourStep({
    required this.id,
    required this.title,
    required this.body,
    this.emoji,
    this.ctaLabel,
    this.isDoStep = false,
  });

  /// Stable identity, persisted as part of the SharedPreferences key (see
  /// [storageKey]). Do not rename an existing step's id after shipping — that
  /// would silently reset every user's progress on it.
  final String id;

  /// Short label shown in the hub's step list.
  final String title;

  /// The "why": what this step is for and why it is worth the interruption.
  /// Shown for the currently-active step in the hub.
  final String body;

  /// Optional leading glyph for the hub row, e.g. '🧭'.
  final String? emoji;

  /// Label for the hub's primary button on this step. Falls back to
  /// [DfTourStrings.defaultCtaLabel] when null.
  final String? ctaLabel;

  /// Whether this step's completion is decided by the app rather than by
  /// whether the tour showed it.
  ///
  /// A "do" step (e.g. "create your first profile") is done the moment the
  /// underlying data exists — even if the user did it outside the tour — so
  /// the app should resolve it via `TourHubSheet.isDoneOverride` /
  /// `TourHelpButton.isDoneOverride` rather than relying on "visited". A plain
  /// "look" step is done once the tour has shown it. This flag is metadata
  /// only; [TourProgress] does not branch on it — it exists so an app's
  /// `isDoneOverride` callback can switch on `step.isDoStep` instead of
  /// hand-matching ids.
  final bool isDoStep;

  /// SharedPreferences key this step's "visited" flag is stored under.
  String get storageKey => 'df_tour_step_$id';

  @override
  bool operator ==(Object other) => other is TourStep && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TourStep($id)';
}
