import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'app_shell_strings.dart';

/// A destination in a [DfNavShell].
@immutable
class DfNavDestination {
  const DfNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
  });

  /// The icon widget (e.g. an [Icon]).
  final Widget icon;

  /// The icon displayed when this destination is selected.
  final Widget? selectedIcon;

  /// The text label for this destination.
  final String label;

  /// An optional badge widget displayed on top of the icon.
  final Widget? badge;

  /// An optional tooltip message.
  final String? tooltip;

  /// Returns [icon] wrapped in [Badge] if [badge] is provided.
  Widget get effectiveIcon => badge != null ? Badge(child: icon) : icon;

  /// Returns [selectedIcon] (or [icon]) wrapped in [Badge] if [badge] is provided.
  Widget get effectiveSelectedIcon => badge != null
      ? Badge(child: selectedIcon ?? icon)
      : (selectedIcon ?? icon);
}

/// Adaptive navigation shell switching between a bottom [NavigationBar] and [NavigationRail].
///
/// Responsive breakpoint defaults to 600dp:
/// - Screen width < [breakpoint]: Displays a bottom [NavigationBar].
/// - Screen width >= [breakpoint]: Displays a side [NavigationRail].
///
/// Tokens and styling are derived from `context.df`.
class DfNavShell extends StatelessWidget {
  const DfNavShell({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.breakpoint = defaultBreakpoint,
    this.leading,
    this.trailing,
    this.appBar,
    this.floatingActionButton,
    this.extended = false,
    this.strings = const DfAppShellStrings(),
    this.backgroundColor,
  });

  /// Default width breakpoint (600.0) between compact and medium/expanded layouts.
  static const double defaultBreakpoint = 600.0;

  /// Currently selected index.
  final int currentIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// List of navigation destinations. Must contain at least two items.
  final List<DfNavDestination> destinations;

  /// The primary view content.
  final Widget body;

  /// Screen width threshold for switching between bottom bar and side rail.
  final double breakpoint;

  /// Optional leading widget in navigation rail.
  final Widget? leading;

  /// Optional trailing widget in navigation rail.
  final Widget? trailing;

  /// Optional scaffold app bar.
  final PreferredSizeWidget? appBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Whether the navigation rail should be in extended format.
  final bool extended;

  /// User-facing strings.
  final DfAppShellStrings strings;

  /// Scaffold background color override. Defaults to `context.df.colors.canvas`.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= breakpoint;
        if (isWide) {
          return Scaffold(
            backgroundColor: backgroundColor ?? df.colors.canvas,
            appBar: appBar,
            floatingActionButton: floatingActionButton,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: extended ? null : NavigationRailLabelType.all,
                  extended: extended,
                  backgroundColor: df.colors.surface,
                  leading: leading,
                  trailing: trailing,
                  destinations: [
                    for (final dest in destinations)
                      NavigationRailDestination(
                        icon: dest.tooltip != null
                            ? Tooltip(
                                message: dest.tooltip!,
                                child: dest.effectiveIcon,
                              )
                            : dest.effectiveIcon,
                        selectedIcon: dest.tooltip != null
                            ? Tooltip(
                                message: dest.tooltip!,
                                child: dest.effectiveSelectedIcon,
                              )
                            : dest.effectiveSelectedIcon,
                        label: Text(dest.label),
                      ),
                  ],
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: df.colors.hairline,
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor ?? df.colors.canvas,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: df.colors.surface,
            destinations: [
              for (final dest in destinations)
                NavigationDestination(
                  icon: dest.effectiveIcon,
                  selectedIcon: dest.effectiveSelectedIcon,
                  label: dest.label,
                  tooltip: dest.tooltip,
                ),
            ],
          ),
        );
      },
    );
  }
}
