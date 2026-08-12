import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// The DF section header: eyebrow, hairline rule, title.
///
/// This is the house signature — a ledger's column heading. TileDom and
/// NaviCare each built their own version of this independently, which is what
/// suggested it belongs in the shared layer.
///
/// It lives in the gallery for now; Phase 4 promotes it to df_ui_widgets so
/// the apps can drop their copies.
class DfSectionHeader extends StatelessWidget {
  const DfSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });

  /// Small, uppercase, tracked. Names the category the title belongs to.
  final String? eyebrow;

  final String title;

  /// An action aligned to the end of the title row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: df.eyebrow),
          SizedBox(height: df.spacing.xs),
        ],
        Divider(color: df.colors.hairline, height: 1, thickness: 1),
        SizedBox(height: df.spacing.sm),
        Row(
          children: [
            Expanded(child: Text(title, style: text.headlineMedium)),
            ?trailing,
          ],
        ),
      ],
    );
  }
}
