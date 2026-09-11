import 'package:flutter/widgets.dart';

import 'df_analytics_core.dart';
import 'screen_name.dart';

/// Picks the reportable screen name for a route, or null to skip it.
typedef DfScreenNameExtractor = String? Function(RouteSettings settings);

/// Reports a `screen_view` whenever a page route comes to the top of the
/// navigator it is attached to.
///
/// ```dart
/// GoRouter(observers: [DfScreenObserver()], ...)
/// ```
///
/// go_router names each page `route.name ?? route.path`, so naming routes gives
/// clean screen names for free. Path-shaped names go through
/// [dfNormaliseScreenName] so `/profiles/42` and `/profiles/99` report as one
/// screen.
///
/// Only [PageRoute]s count: a dialog or bottom sheet is not a new screen, and
/// closing one re-reports the page beneath, which `DfAnalyticsCore.screenView`
/// ignores as a repeat.
///
/// Built on [didChangeTop] rather than push/pop/replace: `context.go()` with
/// go_router rebuilds the page list, and a page dropped that way is *removed*,
/// not popped — an observer listening for pops never learns the user is back
/// on the screen underneath, and GA4 keeps counting time on the page they left.
///
/// Create one observer PER navigator — a [NavigatorObserver] can only be
/// attached to a single navigator (`NavigatorState` asserts on it), so a
/// ShellRoute needs its own instance.
class DfScreenObserver extends NavigatorObserver {
  DfScreenObserver({DfScreenNameExtractor? nameExtractor})
    : nameExtractor = nameExtractor ?? dfDefaultScreenName;

  final DfScreenNameExtractor nameExtractor;

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    super.didChangeTop(topRoute, previousTopRoute);
    _report(topRoute);
  }

  void _report(Route<dynamic> route) {
    if (route is! PageRoute) return;
    final name = nameExtractor(route.settings);
    if (name == null || name.isEmpty) return;
    DfAnalyticsCore.screenView(name);
  }
}
