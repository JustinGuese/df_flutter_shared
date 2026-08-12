import 'package:df_theme/df_theme.dart';
import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'account_settings_strings.dart';

/// The account block every DF settings screen needs: who you are signed in as,
/// support, the legal links, sign out, and delete account.
///
/// DocumentChat and PsychDiary each built this in full; NaviCare's settings
/// screen is roughly 70% this; SocialAnxify was missing delete-account and the
/// legal links entirely — a store-compliance gap, since both Apple and Google
/// require an in-app account-deletion path for apps with accounts.
///
/// Drop it into an existing settings screen; it is a `Column`, not a page, so
/// the app keeps ownership of its own layout and its own app-specific rows.
class DfAccountSettingsSection extends StatelessWidget {
  const DfAccountSettingsSection({
    super.key,
    required this.email,
    required this.onSignOut,
    this.onDeleteAccount,
    this.supportEmail,
    this.privacyPolicyUrl,
    this.termsUrl,
    this.websiteUrl,
    this.appVersion,
    this.strings = const DfAccountSettingsStrings(),
    this.extraRows = const <Widget>[],
  });

  /// Shown as the signed-in identity. Null renders nothing rather than an
  /// empty row.
  final String? email;

  final Future<void> Function() onSignOut;

  /// Deletes the account and all its data. When null the row is hidden — but
  /// hide it only for apps with no accounts at all, since the app stores
  /// require this path when accounts exist.
  final Future<void> Function()? onDeleteAccount;

  /// Opens a prefilled support mail. Include the app version in [appVersion]
  /// and it is added to the subject.
  final String? supportEmail;

  final String? privacyPolicyUrl;
  final String? termsUrl;
  final String? websiteUrl;

  /// Rendered at the bottom, and appended to the support mail subject.
  final String? appVersion;

  final DfAccountSettingsStrings strings;

  /// App-specific rows, placed above sign out.
  final List<Widget> extraRows;

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DfSectionHeader(eyebrow: strings.eyebrow, title: strings.title),
        SizedBox(height: df.spacing.sm),

        if (email != null)
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(strings.signedInAs),
            subtitle: Text(email!),
          ),

        ...extraRows,

        if (supportEmail != null)
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(strings.contactSupport),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openSupportMail(context),
          ),

        if (websiteUrl != null)
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(strings.website),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(context, websiteUrl!),
          ),

        if (privacyPolicyUrl != null)
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(strings.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(context, privacyPolicyUrl!),
          ),

        if (termsUrl != null)
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(strings.terms),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(context, termsUrl!),
          ),

        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(strings.signOut),
          onTap: () => _confirmSignOut(context),
        ),

        if (onDeleteAccount != null)
          ListTile(
            leading: Icon(Icons.delete_forever, color: df.colors.error.base),
            title: Text(
              strings.deleteAccount,
              style: TextStyle(color: df.colors.error.deep),
            ),
            onTap: () => _confirmDelete(context),
          ),

        if (appVersion != null) ...[
          SizedBox(height: df.spacing.md),
          Center(
            child: Text(
              '${strings.versionLabel} $appVersion',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: df.colors.textTertiary),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      DfSnackbar.error(context, strings.couldNotOpenLink);
    }
  }

  Future<void> _openSupportMail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: <String, String>{
        'subject': appVersion == null
            ? strings.supportMailSubject
            : '${strings.supportMailSubject} ($appVersion)',
      },
    );
    // Not every device has a mail client configured, and launchUrl throws
    // rather than returning false for an unhandled scheme.
    try {
      final ok = await launchUrl(uri);
      if (!ok && context.mounted) {
        DfSnackbar.error(context, strings.noMailApp);
      }
    } catch (_) {
      if (context.mounted) DfSnackbar.error(context, strings.noMailApp);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.signOutConfirmTitle),
        content: Text(strings.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.signOut),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await onSignOut();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final df = context.df;
    // Two steps on purpose. Deletion is irreversible and sits one tap from
    // sign out, so a single confirm is not enough separation.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteConfirmTitle),
        content: Text(strings.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.keepAccount),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: df.colors.error.deep,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.deleteAccount),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    if (!context.mounted) return;

    try {
      await onDeleteAccount!();
    } catch (_) {
      if (context.mounted) DfSnackbar.error(context, strings.deleteFailed);
    }
  }
}
