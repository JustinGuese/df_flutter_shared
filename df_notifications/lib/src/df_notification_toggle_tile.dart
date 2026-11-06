import 'dart:async';

import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'df_notification_strings.dart';

/// A settings tile that toggles notification permissions and scheduling.
///
/// Loads the persisted boolean preference from [SharedPreferences] under [prefKey],
/// showing a spinner while loading or toggling.
///
/// When toggled on:
/// 1. Runs [requestPermission] (if supplied).
/// 2. If granted, persists `true`, runs [onEnabled], and shows [DfNotificationStrings.enabledMessage].
/// 3. If denied, leaves preference `false`, resets switch, and shows [DfNotificationStrings.permissionDeniedMessage].
///
/// When toggled off:
/// 1. Persists `false`.
/// 2. Runs [onDisabled].
/// 3. Shows [DfNotificationStrings.disabledMessage].
class DfNotificationToggleTile extends StatefulWidget {
  const DfNotificationToggleTile({
    super.key,
    this.prefKey = defaultNotificationPrefKey,
    this.title,
    this.subtitle,
    this.leading,
    this.icon,
    this.requestPermission,
    this.onEnabled,
    this.onDisabled,
    this.strings = const DfNotificationStrings(),
    this.showFeedbackSnackBar = true,
    this.wrapInCard = true,
    this.decoration,
    this.contentPadding,
  });

  /// Default preference key when [prefKey] is omitted.
  static const String defaultNotificationPrefKey = 'notifications_enabled';

  /// SharedPreferences key for storing the notification enabled state.
  final String prefKey;

  /// Custom title widget. If null, displays [strings.tileTitle].
  final Widget? title;

  /// Custom subtitle widget. If null, displays [strings.tileSubtitle] if non-null.
  final Widget? subtitle;

  /// Custom leading widget. If null, displays a styled container with [icon].
  final Widget? leading;

  /// Icon to show in the leading container when [leading] is null.
  /// Defaults to [Icons.notifications_active_outlined].
  final IconData? icon;

  /// Callback executed when the user toggles on.
  /// Should return `true` if permission is granted.
  /// If null, permission is assumed granted.
  final FutureOr<bool> Function()? requestPermission;

  /// Callback executed when notifications are enabled and permission is granted.
  final FutureOr<void> Function()? onEnabled;

  /// Callback executed when notifications are disabled.
  final FutureOr<void> Function()? onDisabled;

  /// User-facing strings for title, subtitle, and snackbars.
  final DfNotificationStrings strings;

  /// Whether to show a SnackBar on toggle state changes.
  final bool showFeedbackSnackBar;

  /// Whether to wrap the tile inside a rounded card container.
  final bool wrapInCard;

  /// Custom decoration for the wrapping container (only used when [wrapInCard] is true).
  final Decoration? decoration;

  /// Content padding for the [ListTile].
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<DfNotificationToggleTile> createState() =>
      _DfNotificationToggleTileState();
}

class _DfNotificationToggleTileState extends State<DfNotificationToggleTile> {
  bool _enabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  @override
  void didUpdateWidget(covariant DfNotificationToggleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prefKey != widget.prefKey) {
      _loadPreference();
    }
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(widget.prefKey) ?? false;
      if (mounted) {
        setState(() {
          _enabled = value;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleToggle(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (value) {
        final granted = widget.requestPermission != null
            ? await widget.requestPermission!()
            : true;

        if (!mounted) return;

        if (granted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(widget.prefKey, true);

          await widget.onEnabled?.call();

          if (!mounted) return;

          setState(() {
            _enabled = true;
          });

          _showSnackBar(widget.strings.enabledMessage);
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(widget.prefKey, false);

          if (!mounted) return;

          setState(() {
            _enabled = false;
          });

          _showSnackBar(widget.strings.permissionDeniedMessage);
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(widget.prefKey, false);

        await widget.onDisabled?.call();

        if (!mounted) return;

        setState(() {
          _enabled = false;
        });

        _showSnackBar(widget.strings.disabledMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!widget.showFeedbackSnackBar || message.isEmpty) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    final leadingWidget = widget.leading ??
        Container(
          padding: EdgeInsets.all(df.spacing.sm),
          decoration: BoxDecoration(
            color: df.colors.brand.soft.withValues(alpha: 0.4),
            borderRadius: df.shape.radiusSm,
          ),
          child: Icon(
            widget.icon ?? Icons.notifications_active_outlined,
            color: df.colors.brand.base,
            size: 22,
          ),
        );

    final titleWidget = widget.title ??
        Text(
          widget.strings.tileTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: df.colors.textPrimary,
          ),
        );

    final subtitleWidget = widget.subtitle ??
        (widget.strings.tileSubtitle != null
            ? Text(
                widget.strings.tileSubtitle!,
                style: TextStyle(color: df.colors.textSecondary),
              )
            : null);

    final trailingWidget = _isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: df.colors.brand.base,
            ),
          )
        : Switch.adaptive(
            value: _enabled,
            activeColor: df.colors.brand.base,
            onChanged: _handleToggle,
          );

    final tile = ListTile(
      contentPadding: widget.contentPadding ??
          EdgeInsets.symmetric(
            horizontal: df.spacing.lg,
            vertical: df.spacing.xs,
          ),
      leading: leadingWidget,
      title: titleWidget,
      subtitle: subtitleWidget,
      trailing: trailingWidget,
      onTap: _isLoading ? null : () => _handleToggle(!_enabled),
    );

    if (!widget.wrapInCard) {
      return Material(
        type: MaterialType.transparency,
        child: tile,
      );
    }

    return Container(
      decoration: widget.decoration ??
          BoxDecoration(
            color: df.colors.surfaceElevated.withValues(alpha: 0.3),
            borderRadius: df.shape.radiusLg,
            border: Border.all(color: df.colors.hairline),
          ),
      child: Material(
        type: MaterialType.transparency,
        child: tile,
      ),
    );
  }
}
