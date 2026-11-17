import 'package:df_theme/df_theme.dart';
import 'package:material_ui/material_ui.dart';

import 'settings_strings.dart';

/// The top-level scaffold for settings screens in DataFortress apps.
///
/// Provides a consistent layout structure, design-system background styling,
/// and integrated scrollable container for settings groups and sections.
class DfSettingsScaffold extends StatelessWidget {
  const DfSettingsScaffold({
    super.key,
    this.title,
    this.titleText,
    this.appBar,
    this.body,
    this.children = const <Widget>[],
    this.footer,
    this.leading,
    this.actions,
    this.strings = const DfSettingsStrings(),
    this.padding,
    this.physics,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  /// Custom title widget for the app bar.
  final Widget? title;

  /// Custom title text. Defaults to [DfSettingsStrings.settingsTitle] if both
  /// [title] and [titleText] are null.
  final String? titleText;

  /// Custom app bar. Overrides default app bar if supplied.
  final PreferredSizeWidget? appBar;

  /// Custom body. Overrides [children] and [footer] if provided.
  final Widget? body;

  /// Settings groups, sections, and tiles rendered in the scrollable view.
  final List<Widget> children;

  /// Optional footer widget rendered below [children] (e.g. [DfVersionFooter]).
  final Widget? footer;

  /// Leading widget for the default app bar.
  final Widget? leading;

  /// Action widgets for the default app bar.
  final List<Widget>? actions;

  /// Localized strings.
  final DfSettingsStrings strings;

  /// Padding for the scrollable body. Defaults to [DfSpacing.md] horizontal
  /// and [DfSpacing.lg] vertical.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Background color of the scaffold. Defaults to [DfPalette.canvas].
  final Color? backgroundColor;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    final effectiveAppBar =
        appBar ??
        AppBar(
          title: title ?? Text(titleText ?? strings.settingsTitle),
          leading: leading,
          actions: actions,
          backgroundColor: backgroundColor ?? df.colors.canvas,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 1,
        );

    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: df.spacing.md,
          vertical: df.spacing.lg,
        );

    final content =
        body ??
        SafeArea(
          child: SingleChildScrollView(
            physics: physics,
            padding: effectivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
                if (footer != null) ...[
                  SizedBox(height: df.spacing.md),
                  footer!,
                ],
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: effectiveAppBar,
      backgroundColor: backgroundColor ?? df.colors.canvas,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
