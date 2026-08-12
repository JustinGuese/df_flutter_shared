import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'tour_strings.dart';
import 'tour_target.dart';

/// The coach-mark speech bubble: progress dots, title, body.
///
/// Not exported from the package barrel — it's an implementation detail of
/// `showTourCoachMarks`, not part of the public widget surface.
class TourBubble extends StatelessWidget {
  const TourBubble({
    super.key,
    required this.target,
    required this.index,
    required this.total,
    this.strings = const DfTourStrings(),
  });

  final TourTarget target;
  final int index;
  final int total;
  final DfTourStrings strings;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;
    final isLast = index == total - 1;

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      margin: EdgeInsets.symmetric(vertical: df.spacing.mdPlus),
      padding: EdgeInsets.all(df.spacing.md),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: df.shape.radiusLg,
        boxShadow: df.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  target.title,
                  style: text.titleMedium?.copyWith(
                    color: df.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (total > 1)
                Text(
                  '${index + 1}/$total',
                  style: text.labelSmall?.copyWith(
                    color: df.colors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          SizedBox(height: df.spacing.xs),
          Text(
            target.body,
            style: text.bodyMedium?.copyWith(
              color: df.colors.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: df.spacing.sm),
          Row(
            children: [
              if (total > 1)
                // Progress dots rather than a percentage bar — more legible
                // than a bar at the 2-4 target counts a single step usually
                // spotlights.
                for (var i = 0; i < total; i++)
                  Container(
                    width: i == index ? 18 : 6,
                    height: 6,
                    margin: EdgeInsets.only(right: df.spacing.xxs),
                    decoration: BoxDecoration(
                      color: i == index
                          ? df.colors.brand.base
                          : df.colors.hairline,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              const Spacer(),
              Text(
                isLast ? strings.tapToFinishLabel : strings.tapForNextLabel,
                style: text.labelSmall?.copyWith(color: df.colors.textDisabled),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
