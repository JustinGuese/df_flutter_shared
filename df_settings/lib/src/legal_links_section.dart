import 'package:df_theme/df_theme.dart';
import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings_group.dart';
import 'settings_strings.dart';
import 'settings_tile.dart';

/// Injectable URL launcher function. Returns true if successfully launched.
typedef DfUrlLauncher = Future<bool> Function(Uri uri);

Future<bool> _defaultUrlLauncher(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// A settings section containing legal, about, and support links.
///
/// Features:
/// - Privacy policy link
/// - Terms of service link
/// - Website link
/// - Support mail link
/// - Open-source licenses screen
/// - Injectable [launcher] seam for unit testing and custom handling.
class DfLegalLinksSection extends StatelessWidget {
  const DfLegalLinksSection({
    super.key,
    this.privacyPolicyUrl,
    this.termsOfServiceUrl,
    this.termsUrl,
    this.websiteUrl,
    this.supportEmail,
    this.showLicenses = true,
    this.onOpenLicenses,
    this.extraTiles = const <Widget>[],
    this.strings = const DfSettingsStrings(),
    this.launcher,
    this.wrapInGroup = true,
    this.title,
    this.eyebrow,
    this.header,
  });

  /// URL pointing to the Privacy Policy.
  final String? privacyPolicyUrl;

  /// URL pointing to the Terms of Service.
  final String? termsOfServiceUrl;

  /// Alias for [termsOfServiceUrl].
  final String? termsUrl;

  /// URL pointing to the company / app website.
  final String? websiteUrl;

  /// Support email address. Opens with a `mailto:` URI.
  final String? supportEmail;

  /// Whether to include the Flutter open-source licenses tile.
  final bool showLicenses;

  /// Custom handler for opening licenses. Defaults to [showLicensePage].
  final VoidCallback? onOpenLicenses;

  /// Additional custom tiles to render within this section.
  final List<Widget> extraTiles;

  /// Localized strings.
  final DfSettingsStrings strings;

  /// Custom launcher function for URL navigation (injectable for testing).
  final DfUrlLauncher? launcher;

  /// Whether to enclose the tiles inside a [DfSettingsGroup].
  final bool wrapInGroup;

  /// Group title when [wrapInGroup] is true. Defaults to [DfSettingsStrings.legalSectionTitle].
  final String? title;

  /// Optional group eyebrow when [wrapInGroup] is true.
  final String? eyebrow;

  /// Custom group header widget.
  final Widget? header;

  String? get _effectiveTermsUrl => termsOfServiceUrl ?? termsUrl;

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final effectiveLauncher = launcher ?? _defaultUrlLauncher;
      final ok = await effectiveLauncher(uri);
      if (!ok && context.mounted) {
        DfSnackbar.error(context, strings.couldNotOpenLink);
      }
    } catch (_) {
      if (context.mounted) {
        DfSnackbar.error(context, strings.couldNotOpenLink);
      }
    }
  }

  Future<void> _openEmail(BuildContext context, String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': strings.supportMailSubject},
    );
    try {
      final effectiveLauncher = launcher ?? _defaultUrlLauncher;
      final ok = await effectiveLauncher(uri);
      if (!ok && context.mounted) {
        DfSnackbar.error(context, strings.noMailApp);
      }
    } catch (_) {
      if (context.mounted) {
        DfSnackbar.error(context, strings.noMailApp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    final tiles = <Widget>[
      if (privacyPolicyUrl != null)
        DfSettingsTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(strings.privacyPolicy),
          trailing: Icon(
            Icons.open_in_new,
            size: 18,
            color: df.colors.textTertiary,
          ),
          onTap: () => _open(context, privacyPolicyUrl!),
        ),
      if (_effectiveTermsUrl != null)
        DfSettingsTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(strings.termsOfService),
          trailing: Icon(
            Icons.open_in_new,
            size: 18,
            color: df.colors.textTertiary,
          ),
          onTap: () => _open(context, _effectiveTermsUrl!),
        ),
      if (websiteUrl != null)
        DfSettingsTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(strings.website),
          trailing: Icon(
            Icons.open_in_new,
            size: 18,
            color: df.colors.textTertiary,
          ),
          onTap: () => _open(context, websiteUrl!),
        ),
      if (supportEmail != null)
        DfSettingsTile(
          leading: const Icon(Icons.mail_outline),
          title: Text(strings.contactSupport),
          trailing: Icon(
            Icons.open_in_new,
            size: 18,
            color: df.colors.textTertiary,
          ),
          onTap: () => _openEmail(context, supportEmail!),
        ),
      if (showLicenses)
        DfSettingsTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(strings.licenses),
          onTap: () {
            if (onOpenLicenses != null) {
              onOpenLicenses!();
            } else {
              showLicensePage(context: context);
            }
          },
        ),
      ...extraTiles,
    ];

    if (!wrapInGroup) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: tiles,
      );
    }

    return DfSettingsGroup(
      title: title ?? strings.legalSectionTitle,
      eyebrow: eyebrow,
      header: header,
      children: tiles,
    );
  }
}
