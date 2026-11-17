import 'package:material_ui/material_ui.dart';

import 'settings_strings.dart';
import 'settings_tile.dart';

/// A settings tile for selecting the app appearance / theme mode.
///
/// Displays the current [currentMode] and opens a selection dialog when tapped.
class DfThemeModeTile extends StatelessWidget {
  const DfThemeModeTile({
    super.key,
    required this.currentMode,
    this.onModeChanged,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.strings = const DfSettingsStrings(),
    this.enabled = true,
  });

  /// Currently selected [ThemeMode].
  final ThemeMode currentMode;

  /// Callback invoked when a new mode is selected.
  final ValueChanged<ThemeMode>? onModeChanged;

  /// Title widget. Defaults to [DfSettingsStrings.themeTitle].
  final Widget? title;

  /// Subtitle widget. If omitted, displays the localized name of [currentMode].
  final Widget? subtitle;

  /// Leading widget. If omitted, displays an icon matching [currentMode].
  final Widget? leading;

  /// Trailing widget.
  final Widget? trailing;

  /// Localized copy for strings and dialog.
  final DfSettingsStrings strings;

  /// Whether the tile is interactive.
  final bool enabled;

  IconData _iconForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  String _labelForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return strings.themeLight;
      case ThemeMode.dark:
        return strings.themeDark;
      case ThemeMode.system:
        return strings.themeSystem;
    }
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(strings.themeDialogTitle),
          children: [
            RadioGroup<ThemeMode>(
              groupValue: currentMode,
              onChanged: (val) {
                if (val != null) {
                  Navigator.of(context).pop(val);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final mode in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(_labelForMode(mode)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (selected != null && selected != currentMode) {
      onModeChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? Text(strings.themeTitle);
    final effectiveSubtitle = subtitle ?? Text(_labelForMode(currentMode));
    final effectiveLeading = leading ?? Icon(_iconForMode(currentMode));

    return DfSettingsTile(
      title: effectiveTitle,
      subtitle: effectiveSubtitle,
      leading: effectiveLeading,
      trailing: trailing,
      enabled: enabled,
      onTap: enabled && onModeChanged != null
          ? () => _showThemeDialog(context)
          : null,
    );
  }
}
