import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'tour_strings.dart';

/// The hub sheet's gradient header: title, progress bar, drag handle.
///
/// Not exported from the barrel — internal to [TourHubSheet].
class TourHubHeader extends StatelessWidget {
  const TourHubHeader({
    super.key,
    required this.done,
    required this.total,
    required this.allDone,
    this.strings = const DfTourStrings(),
  });

  final int done;
  final int total;
  final bool allDone;
  final DfTourStrings strings;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: df.gradient('header'),
        borderRadius: df.shape.radiusSheet,
      ),
      padding: EdgeInsets.fromLTRB(
        df.spacing.mdPlus,
        df.spacing.sm,
        df.spacing.mdPlus,
        df.spacing.mdPlus,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: EdgeInsets.only(bottom: df.spacing.md),
              decoration: BoxDecoration(
                color: df.colors.textOnBrand.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            allDone ? strings.hubAllDoneTitle : strings.hubTitle,
            style: text.headlineSmall?.copyWith(color: df.colors.textOnBrand),
          ),
          SizedBox(height: df.spacing.xxs + 2),
          Text(
            allDone ? strings.hubAllDoneMessage : strings.hubSubtitle,
            style: text.bodySmall?.copyWith(
              color: df.colors.textOnBrand.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          SizedBox(height: df.spacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 6,
                    backgroundColor: df.colors.textOnBrand.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      df.colors.accent.base,
                    ),
                  ),
                ),
              ),
              SizedBox(width: df.spacing.sm),
              Text(
                strings.progress(done: done, total: total),
                style: text.labelMedium?.copyWith(
                  color: df.colors.textOnBrand,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
