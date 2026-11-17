import 'package:df_theme/df_theme.dart';
import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'settings_strings.dart';
import 'settings_tile.dart';

/// A destructive settings tile for initiating account deletion.
///
/// Mandates a confirmation dialog before executing [onDeleteAccount] to prevent
/// accidental deletions, satisfying Google Play and Apple App Store guidelines.
class DfDeleteAccountTile extends StatelessWidget {
  const DfDeleteAccountTile({
    super.key,
    required this.onDeleteAccount,
    this.strings = const DfSettingsStrings(),
    this.requireConfirmation = true,
    this.showErrorFeedback = true,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.customConfirmationDialog,
  });

  /// The deletion operation. Must be provided when accounts exist.
  final Future<void> Function()? onDeleteAccount;

  /// Localized copy for the tile and confirmation dialog.
  final DfSettingsStrings strings;

  /// Whether an explicit confirmation dialog must be accepted first.
  final bool requireConfirmation;

  /// Whether to display a [DfSnackbar.error] if [onDeleteAccount] throws.
  final bool showErrorFeedback;

  /// Custom title widget. Defaults to [DfSettingsStrings.deleteAccount].
  final Widget? title;

  /// Optional subtitle widget.
  final Widget? subtitle;

  /// Custom leading icon. Defaults to a red delete trash icon.
  final Widget? leading;

  /// Custom trailing widget.
  final Widget? trailing;

  /// Whether the tile is enabled.
  final bool enabled;

  /// Custom confirmation dialog builder if the app needs additional friction
  /// (e.g. typing "DELETE"). Should resolve to `true` when confirmed.
  final Future<bool?> Function(BuildContext context)? customConfirmationDialog;

  Future<bool> _confirm(BuildContext context) async {
    if (customConfirmationDialog != null) {
      final res = await customConfirmationDialog!(context);
      return res ?? false;
    }

    final df = context.df;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteConfirmTitle),
        content: Text(strings.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.keepAccount),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: df.colors.error.deep,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.deleteAccount),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _handleTap(BuildContext context) async {
    if (onDeleteAccount == null) return;

    if (requireConfirmation) {
      final confirmed = await _confirm(context);
      if (!confirmed) return;
    }

    if (!context.mounted) return;

    try {
      await onDeleteAccount!();
    } catch (_) {
      if (showErrorFeedback && context.mounted) {
        DfSnackbar.error(context, strings.deleteFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    final isInteractive = enabled && onDeleteAccount != null;

    return DfSettingsTile(
      isDestructive: true,
      leading:
          leading ??
          Icon(
            Icons.delete_forever,
            color: isInteractive
                ? df.colors.error.base
                : df.colors.textDisabled,
          ),
      title: title ?? Text(strings.deleteAccount),
      subtitle: subtitle,
      trailing: trailing,
      enabled: isInteractive,
      onTap: isInteractive ? () => _handleTap(context) : null,
    );
  }
}
