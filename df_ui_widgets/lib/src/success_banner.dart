import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// A confirmation panel with an optional caveat pill underneath.
///
/// [color] overrides the tint; by default it uses the theme's success role,
/// which is also where the darker title colour comes from. An earlier version
/// tinted the title with the same mid-tone as the fill because there was no
/// token for "success, but darker" — the four-weight roles in df_theme fix
/// that.
class SuccessBanner extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color? color;
  final String? warningNote;
  final IconData warningIcon;
  final Color? warningIconColor;

  const SuccessBanner({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.check_circle,
    this.color,
    this.warningNote,
    this.warningIcon = Icons.info_outline,
    this.warningIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;
    final role = df.colors.success;
    final themeColor = color ?? role.base;
    // When the caller supplies its own tint there is no matching dark weight,
    // so fall back to that tint for the title.
    final titleColor = color == null ? role.deep : color!;

    return Container(
      padding: EdgeInsets.all(df.spacing.lg),
      decoration: BoxDecoration(
        color: color == null ? role.bg : themeColor.withValues(alpha: 0.1),
        borderRadius: df.shape.radiusLg,
        border: Border.all(
          color: color == null ? role.soft : themeColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: themeColor, size: 56),
          SizedBox(height: df.spacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(color: titleColor),
          ),
          SizedBox(height: df.spacing.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: df.colors.textSecondary),
          ),
          if (warningNote != null) ...[
            SizedBox(height: df.spacing.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: df.spacing.md,
                vertical: df.spacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: df.colors.surface.withValues(alpha: 0.6),
                borderRadius: df.shape.radiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(warningIcon, size: 18, color: warningIconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      warningNote!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
