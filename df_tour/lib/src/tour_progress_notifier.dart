import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tour_progress.dart';
import 'tour_step.dart';

/// Whether the tour has ever been auto-opened. Shared across all of an app's
/// steps — if an app runs more than one independent tour, prefix step ids
/// per-tour (e.g. `'onboarding.wissensprofil'`) so their [TourStep.storageKey]
/// values don't collide; [seen] itself is a single app-wide "have they seen
/// any tour" flag, which matches how both source apps used it (one tour each).
const String _kTourSeenKey = 'df_tour_seen';

/// Persists tour progress to SharedPreferences and exposes it as Riverpod
/// state.
///
/// This is deliberately the *only* thing this package persists automatically.
/// "Do" step completion (create a profile, fill a form) is app data and stays
/// in the app's own providers — see [TourStepDoneResolver].
class TourProgressNotifier extends Notifier<TourProgressState> {
  SharedPreferences? _prefs;

  @override
  TourProgressState build() {
    unawaited(_load());
    return const TourProgressState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    // Visited flags are read lazily via hydrate(), not here: SharedPreferences
    // has no "list keys by prefix" API, and steps are app-declared, so at
    // construction time this notifier has no way to know which
    // `df_tour_step_*` keys might exist to read back.
    state = state.copyWith(
      seen: prefs.getBool(_kTourSeenKey) ?? false,
      loaded: true,
    );
  }

  /// Reads back visited flags for a known set of steps.
  ///
  /// Call this once the app's step list is available — typically right before
  /// showing the hub — so previously-visited steps show as done. Idempotent
  /// and cheap; safe to call every time the hub opens. [TourHubSheet.show]
  /// and [TourHelpButton] call this for you.
  Future<void> hydrate(List<TourStep> steps) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final visited = {
      for (final step in steps)
        if (prefs.getBool(step.storageKey) ?? false) step.id,
    };
    state = state.copyWith(visited: {...state.visited, ...visited});
  }

  /// Marks the tour as having been opened. Call this the moment the tour (or
  /// its hub) opens, not when it finishes — otherwise a user who dismisses it
  /// immediately sees it pop up again on every subsequent launch.
  Future<void> markSeen() async {
    if (state.seen) return;
    state = state.copyWith(seen: true);
    await (_prefs ?? await SharedPreferences.getInstance()).setBool(
      _kTourSeenKey,
      true,
    );
  }

  /// Marks a single step as visited (shown to the user).
  Future<void> markVisited(TourStep step) async {
    if (state.visited.contains(step.id)) return;
    state = state.copyWith(visited: {...state.visited, step.id});
    await (_prefs ?? await SharedPreferences.getInstance()).setBool(
      step.storageKey,
      true,
    );
  }

  /// Clears all progress for [steps] plus the "seen" flag. For a "restart
  /// tour" settings action or tests.
  Future<void> reset(List<TourStep> steps) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_kTourSeenKey);
    for (final step in steps) {
      await prefs.remove(step.storageKey);
    }
    state = const TourProgressState(loaded: true);
  }
}

final tourProgressProvider =
    NotifierProvider<TourProgressNotifier, TourProgressState>(
      TourProgressNotifier.new,
    );
