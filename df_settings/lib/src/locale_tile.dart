import 'package:flutter/material.dart';

import 'settings_strings.dart';
import 'settings_tile.dart';

/// Formatter for locale display names.
typedef DfLocaleNameBuilder = String Function(Locale? locale);

/// A settings tile for selecting the application language / locale.
///
/// Displays [currentLocale] and opens a selection dialog when tapped.
class DfLocaleTile extends StatelessWidget {
  const DfLocaleTile({
    super.key,
    required this.currentLocale,
    required this.supportedLocales,
    this.onLocaleChanged,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.strings = const DfSettingsStrings(),
    this.includeSystemDefault = true,
    this.localeNameBuilder,
    this.enabled = true,
  });

  /// Currently active [Locale]. Null represents system default.
  final Locale? currentLocale;

  /// Supported locales available for selection.
  final List<Locale> supportedLocales;

  /// Callback when a new locale is chosen.
  final ValueChanged<Locale?>? onLocaleChanged;

  /// Title widget. Defaults to [DfSettingsStrings.languageTitle].
  final Widget? title;

  /// Subtitle widget. If omitted, displays the name of [currentLocale].
  final Widget? subtitle;

  /// Leading widget. Defaults to a language icon.
  final Widget? leading;

  /// Trailing widget.
  final Widget? trailing;

  /// Localized strings.
  final DfSettingsStrings strings;

  /// Whether to include a "System default" option in the dialog.
  final bool includeSystemDefault;

  /// Custom formatter for locale display names.
  final DfLocaleNameBuilder? localeNameBuilder;

  /// Whether the tile is interactive.
  final bool enabled;

  String _formatLocaleName(Locale? locale) {
    if (localeNameBuilder != null) {
      return localeNameBuilder!(locale);
    }
    if (locale == null) {
      return strings.languageSystem;
    }
    switch (locale.languageCode.toLowerCase()) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'ru':
        return 'Русский';
      case 'ar':
        return 'العربية';
      default:
        return locale.toLanguageTag();
    }
  }

  Future<void> _showLocaleDialog(BuildContext context) async {
    final options = <Locale?>[
      if (includeSystemDefault) null,
      ...supportedLocales,
    ];

    final selected = await showDialog<Locale?>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(strings.languageDialogTitle),
          children: [
            RadioGroup<Locale?>(
              groupValue: currentLocale,
              onChanged: (val) {
                Navigator.of(context).pop(val);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final locale in options)
                    RadioListTile<Locale?>(
                      value: locale,
                      title: Text(_formatLocaleName(locale)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (selected != currentLocale && onLocaleChanged != null) {
      onLocaleChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? Text(strings.languageTitle);
    final effectiveSubtitle =
        subtitle ?? Text(_formatLocaleName(currentLocale));
    final effectiveLeading = leading ?? const Icon(Icons.language_outlined);

    return DfSettingsTile(
      title: effectiveTitle,
      subtitle: effectiveSubtitle,
      leading: effectiveLeading,
      trailing: trailing,
      enabled: enabled,
      onTap: enabled && onLocaleChanged != null
          ? () => _showLocaleDialog(context)
          : null,
    );
  }
}
