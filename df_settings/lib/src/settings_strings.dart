import 'package:flutter/foundation.dart';

/// User-facing copy for [df_settings] components.
///
/// Defaults are English. Pass custom strings or use [DfSettingsStrings.de] for
/// localization.
@immutable
class DfSettingsStrings {
  const DfSettingsStrings({
    this.settingsTitle = 'Settings',
    this.appearanceSectionTitle = 'Appearance',
    this.themeTitle = 'Theme',
    this.themeDialogTitle = 'Choose theme',
    this.themeSystem = 'System default',
    this.themeLight = 'Light',
    this.themeDark = 'Dark',
    this.languageSectionTitle = 'Language',
    this.languageTitle = 'Language',
    this.languageDialogTitle = 'Choose language',
    this.languageSystem = 'System default',
    this.legalSectionTitle = 'Legal & About',
    this.privacyPolicy = 'Privacy policy',
    this.termsOfService = 'Terms of service',
    this.website = 'Website',
    this.contactSupport = 'Contact support',
    this.licenses = 'Open source licenses',
    this.couldNotOpenLink = 'Could not open link.',
    this.deleteAccount = 'Delete account',
    this.deleteConfirmTitle = 'Delete your account?',
    this.deleteConfirmBody =
        'This removes your account and everything in it, on every device. '
        'It cannot be undone.',
    this.keepAccount = 'Keep account',
    this.deleteFailed = 'Could not delete the account. Please try again.',
    this.cancel = 'Cancel',
    this.versionLabel = 'Version',
    this.supportMailSubject = 'Support request',
    this.noMailApp = 'No mail app is set up on this device.',
  });

  /// German strings constructor.
  const DfSettingsStrings.de({
    this.settingsTitle = 'Einstellungen',
    this.appearanceSectionTitle = 'Erscheinungsbild',
    this.themeTitle = 'Design',
    this.themeDialogTitle = 'Design auswählen',
    this.themeSystem = 'Systemstandard',
    this.themeLight = 'Hell',
    this.themeDark = 'Dunkel',
    this.languageSectionTitle = 'Sprache',
    this.languageTitle = 'Sprache',
    this.languageDialogTitle = 'Sprache auswählen',
    this.languageSystem = 'Systemstandard',
    this.legalSectionTitle = 'Rechtliches & Info',
    this.privacyPolicy = 'Datenschutzerklärung',
    this.termsOfService = 'Nutzungsbedingungen',
    this.website = 'Webseite',
    this.contactSupport = 'Support kontaktieren',
    this.licenses = 'Open-Source-Lizenzen',
    this.couldNotOpenLink = 'Link konnte nicht geöffnet werden.',
    this.deleteAccount = 'Konto löschen',
    this.deleteConfirmTitle = 'Konto wirklich löschen?',
    this.deleteConfirmBody =
        'Dadurch wird dein Konto und alle zugehörigen Daten auf allen Geräten unwiderruflich gelöscht.',
    this.keepAccount = 'Konto behalten',
    this.deleteFailed =
        'Konto konnte nicht gelöscht werden. Bitte versuche es erneut.',
    this.cancel = 'Abbrechen',
    this.versionLabel = 'Version',
    this.supportMailSubject = 'Support-Anfrage',
    this.noMailApp = 'Keine E-Mail-App eingerichtet.',
  });

  final String settingsTitle;
  final String appearanceSectionTitle;
  final String themeTitle;
  final String themeDialogTitle;
  final String themeSystem;
  final String themeLight;
  final String themeDark;

  final String languageSectionTitle;
  final String languageTitle;
  final String languageDialogTitle;
  final String languageSystem;

  final String legalSectionTitle;
  final String privacyPolicy;
  final String termsOfService;
  final String website;
  final String contactSupport;
  final String licenses;
  final String couldNotOpenLink;

  final String deleteAccount;
  final String deleteConfirmTitle;
  final String deleteConfirmBody;
  final String keepAccount;
  final String deleteFailed;
  final String cancel;

  final String versionLabel;
  final String supportMailSubject;
  final String noMailApp;
}
