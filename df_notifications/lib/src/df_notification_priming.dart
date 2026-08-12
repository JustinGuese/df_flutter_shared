import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'df_notification_strings.dart';
import 'df_reminder_service.dart';

/// Soft-ask / priming flow before the real OS permission dialog.
///
/// The system notification prompt is a one-shot: once denied, most platforms
/// never show it again for that install. So this first shows an in-app
/// bottom sheet explaining the value, using [strings] for its copy. Only if
/// the user accepts do we fire the OS dialog via
/// [DfReminderService.requestPermission]. Dismissing the sheet returns
/// `false` WITHOUT touching the OS prompt, so it can be offered again later
/// (e.g. after the user has used the app a bit more).
///
/// Returns `true` only when permission ends up granted.
Future<bool> ensureDfNotificationPermission(
  BuildContext context,
  WidgetRef ref, {
  DfNotificationStrings strings = const DfNotificationStrings(),
}) async {
  final wantsIt = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    // Transparent so only the sheet's own df-toned, df-shaped Container
    // paints — the default M3 sheet background would otherwise show through
    // (and clash with) our rounded corners.
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _PrimingSheet(strings: strings),
  );

  if (wantsIt != true) return false;
  if (!context.mounted) return false;

  final service = ref.read(dfReminderServiceProvider);
  return service.requestPermission();
}

class _PrimingSheet extends StatelessWidget {
  const _PrimingSheet({required this.strings});

  final DfNotificationStrings strings;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: df.colors.surface,
          borderRadius: df.shape.radiusSheet,
        ),
        padding: EdgeInsets.fromLTRB(
          df.spacing.lg,
          df.spacing.md,
          df.spacing.lg,
          df.spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: df.colors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: df.spacing.lg),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: df.colors.brand.container,
                borderRadius: df.shape.radiusSm,
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: df.colors.brand.onContainer,
              ),
            ),
            SizedBox(height: df.spacing.md),
            Text(
              strings.primingTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: df.colors.textPrimary,
              ),
            ),
            SizedBox(height: df.spacing.xs),
            Text(
              strings.primingBody,
              style: TextStyle(
                fontSize: 14,
                color: df.colors.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: df.spacing.lg),
            FilledButton.icon(
              icon: const Icon(Icons.check_rounded),
              label: Text(strings.primingAcceptLabel),
              style: FilledButton.styleFrom(
                backgroundColor: df.colors.brandFill,
                foregroundColor: df.colors.textOnBrand,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            SizedBox(height: df.spacing.xs),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.primingDeclineLabel),
            ),
          ],
        ),
      ),
    );
  }
}
