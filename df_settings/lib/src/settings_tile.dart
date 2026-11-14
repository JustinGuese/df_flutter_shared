import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// A single settings row styled with DataFortress tokens.
///
/// Automatically formats title, subtitle, leading, and trailing widgets
/// according to the DF design system. If [onTap] is provided and [trailing]
/// is omitted, a subtle chevron is displayed.
class DfSettingsTile extends StatelessWidget {
  const DfSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.isDestructive = false,
    this.contentPadding,
    this.dense,
  });

  /// The primary content of the tile.
  final Widget title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// Widget displayed before the title (typically an [Icon]).
  final Widget? leading;

  /// Widget displayed after the title. If null and [onTap] is non-null,
  /// defaults to a chevron.
  final Widget? trailing;

  /// Called when the user taps this tile.
  final VoidCallback? onTap;

  /// Whether this tile is interactive.
  final bool enabled;

  /// When true, renders with destructive error colors (e.g. for Delete Account).
  final bool isDestructive;

  /// Internal padding for the tile. Defaults to horizontal [DfSpacing.md].
  final EdgeInsetsGeometry? contentPadding;

  /// Whether this tile is part of a dense list.
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    final titleColor = isDestructive
        ? df.colors.error.deep
        : (enabled ? df.colors.textPrimary : df.colors.textDisabled);

    final subtitleColor = isDestructive
        ? df.colors.error.soft
        : (enabled ? df.colors.textSecondary : df.colors.textDisabled);

    final iconColor = isDestructive
        ? df.colors.error.base
        : (enabled ? df.colors.textSecondary : df.colors.textDisabled);

    Widget? styledLeading = leading;
    if (styledLeading != null) {
      styledLeading = IconTheme(
        data: IconThemeData(color: iconColor, size: 22),
        child: styledLeading,
      );
    }

    Widget? styledTrailing = trailing;
    if (styledTrailing == null && onTap != null) {
      styledTrailing = Icon(
        Icons.chevron_right,
        size: 20,
        color: df.colors.textTertiary,
      );
    } else if (styledTrailing != null) {
      styledTrailing = IconTheme(
        data: IconThemeData(color: df.colors.textTertiary, size: 20),
        child: styledTrailing,
      );
    }

    final effectivePadding =
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal: df.spacing.md,
          vertical: df.spacing.xs,
        );

    return ListTile(
      leading: styledLeading,
      title: DefaultTextStyle.merge(
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w500),
        child: title,
      ),
      subtitle: subtitle != null
          ? DefaultTextStyle.merge(
              style: TextStyle(color: subtitleColor),
              child: subtitle!,
            )
          : null,
      trailing: styledTrailing,
      enabled: enabled,
      dense: dense,
      contentPadding: effectivePadding,
      onTap: enabled ? onTap : null,
    );
  }
}
