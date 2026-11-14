import 'package:df_theme/df_theme.dart';
import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:flutter/material.dart';

/// Groups related settings tiles into a styled card or list with an optional header.
///
/// Designed to provide visual hierarchy and consistency across settings screens.
/// If [card] is true (default), tiles are enclosed in a surface card with hairline
/// borders and separators.
class DfSettingsGroup extends StatelessWidget {
  const DfSettingsGroup({
    super.key,
    required this.children,
    this.title,
    this.eyebrow,
    this.header,
    this.description,
    this.footer,
    this.card = true,
    this.showDividers = true,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  /// The settings tiles in this group.
  final List<Widget> children;

  /// Optional title for the group. Rendered with [DfSectionHeader] if [header] is null.
  final String? title;

  /// Optional eyebrow text shown above [title].
  final String? eyebrow;

  /// Custom header widget. Overrides [title] and [eyebrow] if provided.
  final Widget? header;

  /// Optional explanatory text shown below the group.
  final String? description;

  /// Custom footer widget shown below the group. Overrides [description].
  final Widget? footer;

  /// Whether to wrap children in a rounded surface card.
  final bool card;

  /// Whether to display hairline dividers between children when [card] is true.
  final bool showDividers;

  /// Outer margin around the entire group. Defaults to bottom spacing.
  final EdgeInsetsGeometry? margin;

  /// Inner padding inside the card. Defaults to zero.
  final EdgeInsetsGeometry? padding;

  /// Background color of the card. Defaults to [DfPalette.surface].
  final Color? backgroundColor;

  /// Corner radius of the card. Defaults to [DfShape.radiusMd].
  final BorderRadius? borderRadius;

  /// Border of the card. Defaults to [DfTokens.hairlineBorder].
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    Widget? headerWidget = header;
    if (headerWidget == null && title != null) {
      headerWidget = Padding(
        padding: EdgeInsets.only(bottom: df.spacing.sm),
        child: DfSectionHeader(title: title!, eyebrow: eyebrow),
      );
    }

    Widget? footerWidget = footer;
    if (footerWidget == null && description != null) {
      footerWidget = Padding(
        padding: EdgeInsets.only(
          top: df.spacing.xs,
          left: df.spacing.md,
          right: df.spacing.md,
        ),
        child: Text(
          description!,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: df.colors.textTertiary),
        ),
      );
    }

    Widget content;
    if (card && children.isNotEmpty) {
      final List<Widget> separated = [];
      for (var i = 0; i < children.length; i++) {
        separated.add(children[i]);
        if (showDividers && i < children.length - 1) {
          separated.add(
            Divider(
              height: 1,
              thickness: 1,
              color: df.colors.hairline,
              indent: df.spacing.md,
              endIndent: df.spacing.md,
            ),
          );
        }
      }

      content = Material(
        color: backgroundColor ?? df.colors.surface,
        borderRadius: borderRadius ?? df.shape.radiusMd,
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? df.shape.radiusMd,
            border: border ?? df.hairlineBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: separated,
          ),
        ),
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.only(bottom: df.spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [?headerWidget, content, ?footerWidget],
      ),
    );
  }
}
