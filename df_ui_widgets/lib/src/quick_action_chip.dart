import 'package:flutter/material.dart';

/// A standardized quick action chip button.
///
/// Optional [gradient], [iconColor], [labelColor] allow branding; when null
/// uses theme.colorScheme.primary and onPrimary.
class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.theme,
    this.compact = false,
    this.gradient,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ThemeData? theme;

  /// When true, uses reduced padding and font size for a tighter fit.
  final bool compact;

  /// When null, uses a solid fill from theme primary.
  final Gradient? gradient;

  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final t = theme ?? Theme.of(context);
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.colorScheme.primary,
            t.colorScheme.primary,
          ],
        );
    final effectiveIconColor = iconColor ?? t.colorScheme.onPrimary;
    final effectiveLabelColor = labelColor ?? t.colorScheme.onPrimary;

    final horizontalPadding = compact ? 10.0 : 16.0;
    final verticalPadding = compact ? 8.0 : 10.0;
    final iconSize = compact ? 14.0 : 16.0;
    final fontSize = compact ? 13.0 : 14.0;
    final iconGap = compact ? 4.0 : 6.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: effectiveIconColor,
                ),
                SizedBox(width: iconGap),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: effectiveLabelColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
