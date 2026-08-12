import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'tour_step.dart';
import 'tour_strings.dart';

/// One row in the hub's step list.
///
/// The next open step is expanded with its "why" and a filled CTA; every
/// other step collapses to a title so the sheet doesn't read as a wall of
/// text nobody scrolls through. Not exported from the barrel — internal to
/// [TourHubSheet].
class TourHubStepRow extends StatelessWidget {
  const TourHubStepRow({
    super.key,
    required this.step,
    required this.index,
    required this.isNext,
    required this.isDone,
    required this.onStart,
    this.strings = const DfTourStrings(),
  });

  final TourStep step;
  final int index;
  final bool isNext;
  final bool isDone;
  final VoidCallback onStart;
  final DfTourStrings strings;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: df.spacing.sm),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: df.shape.radiusMd,
        border: Border.all(
          color: isNext ? df.colors.brand.base : df.colors.hairline,
          width: isNext ? 1.5 : 1,
        ),
      ),
      padding: EdgeInsets.all(df.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TourHubStatusDot(isDone: isDone, isNext: isNext, index: index),
              SizedBox(width: df.spacing.sm),
              Expanded(
                child: Text(
                  [if (step.emoji != null) step.emoji, step.title].join('  '),
                  style: text.titleSmall?.copyWith(
                    color: isDone
                        ? df.colors.textTertiary
                        : df.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Done steps stay reachable, just unobtrusively.
              if (isDone)
                TextButton(
                  onPressed: onStart,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: EdgeInsets.symmetric(horizontal: df.spacing.xs),
                  ),
                  child: Text(strings.replayLabel, style: text.labelSmall),
                ),
            ],
          ),
          // The "why" only on the active step — otherwise the sheet becomes a
          // wall of text nobody reads.
          if (isNext) ...[
            SizedBox(height: df.spacing.xs + 2),
            Text(
              step.body,
              style: text.bodySmall?.copyWith(
                color: df.colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: df.spacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onStart,
                child: Text(step.ctaLabel ?? strings.defaultCtaLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The numbered/checked circle at the start of a [TourHubStepRow].
class TourHubStatusDot extends StatelessWidget {
  const TourHubStatusDot({
    super.key,
    required this.isDone,
    required this.isNext,
    required this.index,
  });

  final bool isDone;
  final bool isNext;
  final int index;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final bg = isDone
        ? df.colors.success.base
        : isNext
        ? df.colors.brand.base
        : df.colors.hairline;

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: isDone
          ? Icon(Icons.check, size: 15, color: df.colors.textOnBrand)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isNext ? df.colors.textOnBrand : df.colors.textTertiary,
              ),
            ),
    );
  }
}
