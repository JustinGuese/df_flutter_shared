import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps user experience from stacking interruptions (in-app prompts,
/// rate prompts, upsell sheets, sign-in sheets).
///
/// Ensures at least [minEventsBetween] discrete events (e.g. swipes, opens,
/// completed tasks) elapse before another prompt may show.
///
/// [reserve] is synchronous so two prompts evaluated for the same event
/// cannot both pass; a prompt that then decides not to show calls [release].
class DfPromptScheduler extends Notifier<int?> {
  DfPromptScheduler({this.minEventsBetween = defaultMinEventsBetween});

  /// Default spacing between prompts if unspecified.
  static const int defaultMinEventsBetween = 5;

  /// Minimum number of events required between prompt displays.
  final int minEventsBetween;

  int? _previous;

  /// Event count at which the last prompt showed (null if none shown this session).
  @override
  int? build() => null;

  /// Attempts to reserve a prompt display slot at [eventCount].
  ///
  /// Returns `true` if at least [minEventsBetween] (or the optional override)
  /// events have occurred since the last reserved prompt.
  /// Synchronous so concurrent checks on the same event cannot both pass.
  bool reserve(int eventCount, {int? minEventsBetween}) {
    final effectiveMin = minEventsBetween ?? this.minEventsBetween;
    final last = state;
    if (last != null && (eventCount - last) < effectiveMin) {
      return false;
    }
    _previous = last;
    state = eventCount;
    return true;
  }

  /// Cancels the most recent reservation, restoring the previous state.
  /// Call this when a prompt was reserved but ultimately not presented.
  void release() {
    state = _previous;
  }
}

/// Default provider for [DfPromptScheduler].
final dfPromptSchedulerProvider = NotifierProvider<DfPromptScheduler, int?>(
  DfPromptScheduler.new,
);

/// Family provider allowing different [minEventsBetween] thresholds per scope.
final dfPromptSchedulerFamily =
    NotifierProvider.family<DfPromptScheduler, int?, int>(
      (arg) => DfPromptScheduler(minEventsBetween: arg),
    );
