import 'package:flutter/material.dart';

/// Bullet list with optional title/icon and "+X more" truncation.
///
/// [titleIconGradient] is used for the optional title icon container; when null
/// uses a theme-based default.
class SummaryBulletList extends StatelessWidget {
  const SummaryBulletList({
    super.key,
    required this.points,
    this.title,
    this.icon,
    this.emptyStateText,
    this.isLoading = false,
    this.maxVisible,
    this.textStyle,
    this.compact = false,
    this.titleColor,
    this.bulletColor,
    this.titleIconGradient,
  });

  final List<String> points;
  final String? title;
  final IconData? icon;
  final String? emptyStateText;
  final bool isLoading;
  final int? maxVisible;
  final TextStyle? textStyle;
  final bool compact;
  final Color? titleColor;
  final Color? bulletColor;

  /// Gradient for the title icon circle. When null, uses theme primary.
  final Gradient? titleIconGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visiblePoints =
        maxVisible != null ? points.take(maxVisible!).toList() : points;
    final effectiveBulletColor = bulletColor ??
        (compact ? theme.colorScheme.outline : theme.colorScheme.primary);
    final bulletSize = compact ? 6.0 : 8.0;
    final spacing = compact ? 6.0 : 10.0;

    final effectiveTitleIconGradient = titleIconGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary,
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: effectiveTitleIconGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: compact ? 16 : 18,
                    color: Colors.white,
                  ),
                ),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title!,
                style: (() {
                  final base = theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700);
                  if (titleColor == null) return base;
                  return base?.copyWith(color: titleColor);
                })(),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
        ],
        if (isLoading) ...[
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Generating summary...',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ] else if (visiblePoints.isEmpty) ...[
          if (emptyStateText != null)
            Text(
              emptyStateText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ] else ...[
          ...visiblePoints.map(
            (point) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: compact ? 6 : 8),
                    child: Container(
                      width: bulletSize,
                      height: bulletSize,
                      decoration: BoxDecoration(
                        color: effectiveBulletColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: textStyle ?? theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (maxVisible != null && points.length > maxVisible!)
            Text(
              '+${points.length - maxVisible!} more',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ],
    );
  }
}
