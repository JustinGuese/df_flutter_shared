import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import '../main.dart' show GallerySection;

/// The type scale, plus the tabular figures DF apps rely on.
class TypeSection extends StatelessWidget {
  const TypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final t = Theme.of(context).textTheme;

    final specimens = <String, TextStyle?>{
      'displayLarge': t.displayLarge,
      'displayMedium': t.displayMedium,
      'displaySmall': t.displaySmall,
      'headlineMedium': t.headlineMedium,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'bodyLarge': t.bodyLarge,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelLarge': t.labelLarge,
      'labelMedium': t.labelMedium,
      'labelSmall': t.labelSmall,
    };

    return GallerySection(
      eyebrow: 'Tokens',
      title: 'Type scale',
      children: [
        Container(
          padding: EdgeInsets.all(df.spacing.md),
          decoration: BoxDecoration(
            color: df.colors.surface,
            borderRadius: df.shape.radiusMd,
            border: df.hairlineBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in specimens.entries) ...[
                Text(s.key, style: t.labelSmall),
                Text('Carry what matters', style: s.value),
                SizedBox(height: df.spacing.sm),
              ],
            ],
          ),
        ),
        SizedBox(height: df.spacing.md),
        _FigureBlock(),
      ],
    );
  }
}

/// Tabular figures: the columns must align and a changing value must not
/// shift the ones beside it.
class _FigureBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final rows = <String, String>{
      'Pflegegrad score': '  86.5',
      'Streak': '  14',
      'Balance': '1 204.00',
      'Elapsed': '00:07:31',
    };

    return Container(
      padding: EdgeInsets.all(df.spacing.md),
      decoration: BoxDecoration(
        color: df.colors.surfaceSunken,
        borderRadius: df.shape.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TABULAR FIGURES', style: df.eyebrow),
          SizedBox(height: df.spacing.sm),
          for (final r in rows.entries)
            Padding(
              padding: EdgeInsets.only(bottom: df.spacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.key, style: Theme.of(context).textTheme.bodySmall),
                  Text(r.value, style: df.dataMedium),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
