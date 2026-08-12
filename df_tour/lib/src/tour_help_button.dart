import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tour_hub_sheet.dart';
import 'tour_progress.dart';
import 'tour_progress_notifier.dart';
import 'tour_step.dart';
import 'tour_strings.dart';

/// A "?" button that opens [TourHubSheet], with a small dot while steps
/// remain so the tour stays findable after the first dismissal.
///
/// Styled for a brand-coloured header/app bar (uses [DfPalette.textOnBrand]
/// for its icon and background wash) — drop it next to a settings icon in a
/// header, not on a plain surface.
class TourHelpButton extends ConsumerWidget {
  const TourHelpButton({
    super.key,
    required this.steps,
    required this.onStartStep,
    this.isDoneOverride,
    this.strings = const DfTourStrings(),
  });

  final List<TourStep> steps;
  final Future<void> Function(BuildContext context, TourStep step) onStartStep;
  final TourStepDoneResolver? isDoneOverride;
  final DfTourStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = context.df;
    final visited = ref.watch(tourProgressProvider).visited;
    final hasOpenSteps =
        TourProgress.nextStep(steps, visited, isDoneOverride: isDoneOverride) !=
        null;

    return Container(
      decoration: BoxDecoration(
        color: df.colors.textOnBrand.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: strings.helpTooltip,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.help_outline, color: df.colors.textOnBrand, size: 22),
            if (hasOpenSteps)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: df.colors.accent.base,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        onPressed: () => TourHubSheet.show(
          context,
          ref,
          steps: steps,
          onStartStep: onStartStep,
          isDoneOverride: isDoneOverride,
          strings: strings,
        ),
      ),
    );
  }
}
