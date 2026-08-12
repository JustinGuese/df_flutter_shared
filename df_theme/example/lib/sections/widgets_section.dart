import 'package:df_theme/df_theme.dart';
import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:flutter/material.dart';

import '../main.dart' show GallerySection;

/// The shared widgets from df_ui_widgets, rendered under the selected brand.
///
/// These are the ones the apps were each re-implementing: a scroll affordance,
/// the async/empty/error trio, and the section header.
class WidgetsSection extends StatelessWidget {
  const WidgetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    return GallerySection(
      eyebrow: 'df_ui_widgets',
      title: 'Shared widgets',
      children: [
        _Labelled(
          label: 'DfSectionHeader',
          child: const DfSectionHeader(
            eyebrow: 'This week',
            title: 'Entries',
            subtitle: 'Four written, two analysed.',
          ),
        ),
        _Labelled(
          label: 'DfEmptyState',
          child: DfEmptyState(
            icon: Icons.edit_note,
            title: 'No entries yet',
            message: 'Write your first one and it will show up here.',
            action: FilledButton(
              onPressed: () {},
              child: const Text('Write an entry'),
            ),
          ),
        ),
        _Labelled(
          label: 'DfErrorState',
          child: DfErrorState(
            title: 'Could not reach the server',
            message: 'Check your connection and try again.',
            onRetry: () {},
          ),
        ),
        _Labelled(
          label: 'DfErrorState (compact)',
          child: const DfErrorState(
            title: 'Analysis unavailable',
            message: 'The rest of this entry loaded fine.',
            compact: true,
          ),
        ),
        _Labelled(
          label: 'DfLoading',
          child: const DfLoading(label: 'Loading entries'),
        ),
        _Labelled(
          label: 'SuccessBanner',
          child: const SuccessBanner(
            title: 'All set',
            body: 'Your reminder is scheduled for 20:00 each evening.',
            warningNote: 'Notifications must stay enabled in system settings.',
          ),
        ),
        _Labelled(
          label: 'ScrollHint — fades and bounces while content remains',
          child: SizedBox(
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: df.colors.surface,
                borderRadius: df.shape.radiusMd,
                border: df.hairlineBorder,
              ),
              child: ClipRRect(
                borderRadius: df.shape.radiusMd,
                child: ScrollHint(
                  backgroundColor: df.colors.surface,
                  child: ListView(
                    padding: EdgeInsets.all(df.spacing.md),
                    children: [
                      for (var i = 1; i <= 12; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: df.spacing.xs),
                          child: Text('Scrollable row $i'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _Labelled(
          label: 'DfSnackbar',
          child: Wrap(
            spacing: df.spacing.xs,
            children: [
              OutlinedButton(
                onPressed: () => DfSnackbar.show(
                  context,
                  'Entry saved.',
                  actionLabel: 'Undo',
                  onAction: () {},
                ),
                child: const Text('Confirmation'),
              ),
              OutlinedButton(
                onPressed: () => DfSnackbar.error(
                  context,
                  'Could not save. Your text is still here.',
                ),
                child: const Text('Failure'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Padding(
      padding: EdgeInsets.only(bottom: df.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          SizedBox(height: df.spacing.xs),
          child,
        ],
      ),
    );
  }
}
