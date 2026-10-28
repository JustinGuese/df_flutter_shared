import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'swipe_strings.dart';

/// Progress bar showing completed items count out of total items.
///
/// Designed to sit directly above [DfSwipeDeck].
class DfDeckProgressBar extends StatelessWidget {
  const DfDeckProgressBar({
    super.key,
    int? current,
    int? read,
    required this.total,
    this.strings = const DfSwipeStrings(),
  }) : current = current ?? read ?? 0;

  /// Number of items completed or read.
  final int current;

  /// Total number of items in the deck.
  final int total;

  /// Strings used for formatting the progress text.
  final DfSwipeStrings strings;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final clampedCurrent = total <= 0 ? 0 : current.clamp(0, total);
    final progressValue = total <= 0 ? 0.0 : clampedCurrent / total;

    return Padding(
      padding: EdgeInsets.only(bottom: df.spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: df.shape.radiusPill,
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 3,
                backgroundColor: df.colors.hairline,
                color: df.colors.brand.base,
              ),
            ),
          ),
          SizedBox(width: df.spacing.sm),
          Text(
            strings.fillProgress(current: clampedCurrent, total: total),
            style: df.eyebrow,
          ),
        ],
      ),
    );
  }
}
