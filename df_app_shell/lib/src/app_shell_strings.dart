import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-facing copy for the app shell, theme mode, and navigation.
///
/// English defaults: a shared package must not impose language copy.
@immutable
class DfAppShellStrings {
  const DfAppShellStrings({
    this.systemThemeLabel = 'System',
    this.lightThemeLabel = 'Light',
    this.darkThemeLabel = 'Dark',
    this.systemLocaleLabel = 'System default',
    this.navigationTooltip = 'Navigation',
  });

  /// German strings.
  const DfAppShellStrings.de({
    this.systemThemeLabel = 'System',
    this.lightThemeLabel = 'Hell',
    this.darkThemeLabel = 'Dunkel',
    this.systemLocaleLabel = 'Systemstandard',
    this.navigationTooltip = 'Navigation',
  });

  /// Label for system theme mode.
  final String systemThemeLabel;

  /// Label for light theme mode.
  final String lightThemeLabel;

  /// Label for dark theme mode.
  final String darkThemeLabel;

  /// Label for system locale choice.
  final String systemLocaleLabel;

  /// General tooltip or semantic label for navigation.
  final String navigationTooltip;
}

/// Optional provider for [DfAppShellStrings] overrides.
final dfAppShellStringsProvider = Provider<DfAppShellStrings>((ref) {
  return const DfAppShellStrings();
});
