import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../df_feedback_prompt/lib/src/cooldown.dart';
import '../../../df_feedback_prompt/lib/src/prompt_scheduler.dart';

export '../../../df_feedback_prompt/lib/src/cooldown.dart';
export '../../../df_feedback_prompt/lib/src/prompt_scheduler.dart';

/// Callback invoked to display a prompt interruption.
///
/// Return `true` (or `null`) if the prompt was displayed.
/// Return `false` if the prompt decided not to show, releasing the scheduler reservation.
typedef DfPromptAction = FutureOr<bool?> Function(BuildContext? context);

/// Custom predicate returning whether a prompt is eligible to display.
typedef DfPromptCondition = FutureOr<bool> Function(BuildContext? context);

/// A candidate interruption in a [DfPromptChain].
class DfPrompt {
  const DfPrompt({
    this.id,
    this.priority = 0,
    this.minEvents,
    this.cooldown,
    this.canShow,
    required this.show,
  });

  /// Optional identifier for debugging or analytics.
  final String? id;

  /// Priority of this prompt. Higher values take precedence.
  /// When priorities are equal, the chain evaluates prompts in list order.
  final int priority;

  /// Minimum event count required before this prompt may show.
  final int? minEvents;

  /// Optional persistent cooldown preventing repeat displays.
  final DfCooldown? cooldown;

  /// Optional predicate evaluated before presenting this prompt.
  final DfPromptCondition? canShow;

  /// Action that displays the prompt interruption.
  final DfPromptAction show;

  /// Checks whether this prompt is currently eligible to be shown.
  Future<bool> isEligible(
    int eventCount, {
    BuildContext? context,
    SharedPreferences? prefs,
  }) async {
    if (minEvents != null && eventCount < minEvents!) {
      return false;
    }
    if (cooldown != null) {
      final ready = await cooldown!.isReady(prefs: prefs);
      if (!ready) return false;
    }
    if (canShow != null) {
      final can = await canShow!(context);
      if (!can) return false;
    }
    return true;
  }
}

/// Priority-ordered prompt chain running interruptions after an event count.
///
/// Uses [DfPromptScheduler] to space interruptions and ensure at most one prompt
/// is shown per reservation. Uses [DfCooldown] on individual [DfPrompt]s to
/// prevent prompt repeats.
class DfPromptChain {
  DfPromptChain(
    this.prompts, {
    DfPromptScheduler? scheduler,
    this.minEventsBetween,
    this.prefs,
  }) : scheduler = _ensureInitialized(scheduler, minEventsBetween);

  /// The candidate prompts in this chain.
  final List<DfPrompt> prompts;

  /// Scheduler that spaces prompt reservations.
  final DfPromptScheduler scheduler;

  /// Optional spacing override between prompts.
  final int? minEventsBetween;

  /// Optional [SharedPreferences] instance for cooldown tracking.
  final SharedPreferences? prefs;

  static DfPromptScheduler _ensureInitialized(
    DfPromptScheduler? scheduler,
    int? minEventsBetween,
  ) {
    if (scheduler != null) {
      try {
        scheduler.state;
        return scheduler;
      } catch (_) {
        final container = ProviderContainer();
        final provider =
            NotifierProvider<DfPromptScheduler, int?>(() => scheduler);
        return container.read(provider.notifier);
      }
    }
    final container = ProviderContainer();
    if (minEventsBetween != null) {
      return container.read(dfPromptSchedulerFamily(minEventsBetween).notifier);
    }
    return container.read(dfPromptSchedulerProvider.notifier);
  }

  /// Checks whether the scheduler can reserve a slot at [eventCount].
  bool canReserve(int eventCount, {int? minEventsBetween}) {
    final effectiveMin =
        minEventsBetween ?? this.minEventsBetween ?? scheduler.minEventsBetween;
    final last = scheduler.state;
    return last == null || (eventCount - last) >= effectiveMin;
  }

  /// Evaluates prompts in priority order and shows at most one for [eventCount].
  ///
  /// Returns `true` if a prompt was shown, `false` otherwise.
  Future<bool> run(
    int eventCount, {
    BuildContext? context,
    SharedPreferences? prefs,
    int? minEventsBetween,
  }) async {
    final effectiveMin = minEventsBetween ?? this.minEventsBetween;

    if (!canReserve(eventCount, minEventsBetween: effectiveMin)) {
      return false;
    }

    final effectivePrefs = prefs ?? this.prefs;

    // Stable sort by priority descending (preserves list order for ties).
    final indexed = prompts.asMap().entries.toList();
    indexed.sort((a, b) {
      final p = b.value.priority.compareTo(a.value.priority);
      if (p != 0) return p;
      return a.key.compareTo(b.key);
    });
    final sortedPrompts = indexed.map((e) => e.value).toList();

    for (final prompt in sortedPrompts) {
      if (context != null && !context.mounted) return false;

      final eligible = await prompt.isEligible(
        eventCount,
        context: context,
        prefs: effectivePrefs,
      );
      if (!eligible) continue;

      if (context != null && !context.mounted) return false;

      if (!scheduler.reserve(eventCount, minEventsBetween: effectiveMin)) {
        return false;
      }

      final result = await prompt.show(context);
      final shown = result != false;

      if (shown) {
        if (prompt.cooldown != null) {
          await prompt.cooldown!.mark(prefs: effectivePrefs);
        }
        return true;
      } else {
        scheduler.release();
      }
    }

    return false;
  }

  /// Shorthand alias for [run].
  Future<bool> maybeShow(
    int eventCount, {
    BuildContext? context,
    SharedPreferences? prefs,
    int? minEventsBetween,
  }) =>
      run(
        eventCount,
        context: context,
        prefs: prefs,
        minEventsBetween: minEventsBetween,
      );

  /// Shorthand alias for [run].
  Future<bool> afterEvent(
    int eventCount, {
    BuildContext? context,
    SharedPreferences? prefs,
    int? minEventsBetween,
  }) =>
      run(
        eventCount,
        context: context,
        prefs: prefs,
        minEventsBetween: minEventsBetween,
      );

  /// Callable invocation forwarded to [run].
  Future<bool> call(
    int eventCount, {
    BuildContext? context,
    SharedPreferences? prefs,
    int? minEventsBetween,
  }) =>
      run(
        eventCount,
        context: context,
        prefs: prefs,
        minEventsBetween: minEventsBetween,
      );
}
