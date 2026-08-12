import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import '../main.dart' show GallerySection;

/// Semantic states: banners, dialogs, snackbars.
///
/// Colour alone never carries the meaning here — every state pairs its colour
/// with an icon, so the distinction survives colour-blindness and greyscale.
class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final c = df.colors;

    return GallerySection(
      eyebrow: 'Feedback',
      title: 'States & messages',
      children: [
        _Banner(
          role: c.success,
          icon: Icons.check_circle_outline,
          title: 'Entry saved',
          body: 'Your entry is stored on this device and synced.',
        ),
        SizedBox(height: df.spacing.xs),
        _Banner(
          role: c.info,
          icon: Icons.info_outline,
          title: 'Analysis runs overnight',
          body: 'Results appear on your dashboard tomorrow morning.',
        ),
        SizedBox(height: df.spacing.xs),
        _Banner(
          role: c.warning,
          icon: Icons.warning_amber_outlined,
          title: 'Reminders are off',
          body: 'Turn on notifications to keep your streak going.',
        ),
        SizedBox(height: df.spacing.xs),
        _Banner(
          role: c.error,
          icon: Icons.error_outline,
          title: 'Could not reach the server',
          body: 'Check your connection and try again.',
        ),
        SizedBox(height: df.spacing.md),
        Wrap(
          spacing: df.spacing.xs,
          runSpacing: df.spacing.xs,
          children: [
            OutlinedButton(
              onPressed: () => _showDialog(context),
              child: const Text('Show dialog'),
            ),
            OutlinedButton(
              onPressed: () => _showSnackBar(context),
              child: const Text('Show snackbar'),
            ),
            OutlinedButton(
              onPressed: () => _showSheet(context),
              child: const Text('Show sheet'),
            ),
          ],
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text(
          'The entry and its analysis are removed from every device. This '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep entry'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry deleted.'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final df = context.df;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          df.spacing.md,
          0,
          df.spacing.md,
          df.spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: df.spacing.sm),
            Text(
              'Download everything you have written as a single PDF.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: df.spacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Export PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.role,
    required this.icon,
    required this.title,
    required this.body,
  });

  final DfColorRole role;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(df.spacing.sm),
      decoration: BoxDecoration(
        color: role.bg,
        borderRadius: df.shape.radiusMd,
        border: Border.all(color: role.soft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: role.deep, size: 20),
          SizedBox(width: df.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall?.copyWith(color: role.deep)),
                SizedBox(height: df.spacing.xxs),
                Text(body, style: t.bodySmall?.copyWith(color: role.deep)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
