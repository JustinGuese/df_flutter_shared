import 'dart:async';

import 'package:df_theme/df_theme.dart';
import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tour_hub_header.dart';
import 'tour_hub_step_row.dart';
import 'tour_progress.dart';
import 'tour_progress_notifier.dart';
import 'tour_step.dart';
import 'tour_strings.dart';

/// The tour hub: progress across every declared step, with the first open
/// step expanded and a single dominant action.
///
/// The hub owns step order and progress; each screen only needs to know its
/// own coach marks (built with `showTourCoachMarks`). That split means a
/// screen that's still loading doesn't break the whole tour — its step just
/// stays open.
class TourHubSheet extends ConsumerWidget {
  const TourHubSheet({
    super.key,
    required this.steps,
    required this.onStartStep,
    this.isDoneOverride,
    this.strings = const DfTourStrings(),
  });

  /// The app's declared steps, in the order the hub should show them.
  final List<TourStep> steps;

  /// Called (with the hub already dismissed) when the user starts or
  /// replays a step — e.g. push the step's screen, or open a dialog.
  final Future<void> Function(BuildContext context, TourStep step) onStartStep;

  /// Resolves "do" steps against real app data instead of "was it visited".
  /// See [TourStepDoneResolver].
  final TourStepDoneResolver? isDoneOverride;

  final DfTourStrings strings;

  /// Opens the hub as a modal bottom sheet.
  ///
  /// Hydrates progress for [steps] and marks the tour seen before the sheet
  /// even finishes opening — not on completion, so a user who swipes it away
  /// immediately doesn't see it pop up again on next launch.
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required List<TourStep> steps,
    required Future<void> Function(BuildContext context, TourStep step)
    onStartStep,
    TourStepDoneResolver? isDoneOverride,
    DfTourStrings strings = const DfTourStrings(),
  }) {
    final notifier = ref.read(tourProgressProvider.notifier);
    unawaited(notifier.hydrate(steps));
    unawaited(notifier.markSeen());
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TourHubSheet(
        steps: steps,
        onStartStep: onStartStep,
        isDoneOverride: isDoneOverride,
        strings: strings,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = context.df;
    final visited = ref.watch(tourProgressProvider).visited;
    final done = TourProgress.doneCount(
      steps,
      visited,
      isDoneOverride: isDoneOverride,
    );
    final next = TourProgress.nextStep(
      steps,
      visited,
      isDoneOverride: isDoneOverride,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: df.colors.canvas,
        borderRadius: df.shape.radiusSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TourHubHeader(
            done: done,
            total: steps.length,
            allDone: next == null,
            strings: strings,
          ),
          Flexible(
            // A caller that hasn't wired up its steps yet (or filtered them
            // down to nothing) gets an explanatory empty state instead of a
            // silently blank sheet.
            child: steps.isEmpty
                ? const DfEmptyState(
                    title: 'No tour steps',
                    message: 'This tour has nothing configured yet.',
                    icon: Icons.explore_off_outlined,
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(
                      df.spacing.md,
                      df.spacing.md,
                      df.spacing.md,
                      df.spacing.sm,
                    ),
                    children: [
                      for (var i = 0; i < steps.length; i++)
                        TourHubStepRow(
                          step: steps[i],
                          index: i,
                          isNext: steps[i] == next,
                          isDone: TourProgress.isDone(
                            steps[i],
                            visited,
                            isDoneOverride: isDoneOverride,
                          ),
                          onStart: () => _start(context, steps[i]),
                          strings: strings,
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                df.spacing.md,
                0,
                df.spacing.md,
                df.spacing.sm,
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  next == null
                      ? strings.closeLabel
                      : strings.continueLaterLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _start(BuildContext context, TourStep step) {
    Navigator.of(context).pop();
    unawaited(onStartStep(context, step));
  }
}
