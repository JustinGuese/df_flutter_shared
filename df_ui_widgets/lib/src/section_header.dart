import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// Eyebrow, hairline rule, title — the DF section header.
///
/// This is the house signature, and it was arrived at rather than invented:
/// TileDom and NaviCare independently built a `SectionHeader` with the same
/// `title` / `eyebrow` / `trailing` shape before this package existed.
///
/// The eyebrow names the category the title belongs to, so it should carry
/// information ("Tokens", "This week", "Step 2 of 5") rather than restate the
/// title. Leave it off when there is nothing true to put there.
class DfSectionHeader extends StatelessWidget {
  const DfSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.trailing,
  });

  /// Small, uppercase, tracked. Uppercasing is applied for you.
  final String? eyebrow;

  final String title;

  /// Optional line under the title.
  final String? subtitle;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(title, style: text.headlineMedium)),
            ?trailing,
          ],
        ),
        if (subtitle != null) ...[
          SizedBox(height: df.spacing.xxs),
          Text(
            subtitle!,
            style: text.bodySmall?.copyWith(color: df.colors.textSecondary),
          ),
        ],
      ],
    );
  }
}
