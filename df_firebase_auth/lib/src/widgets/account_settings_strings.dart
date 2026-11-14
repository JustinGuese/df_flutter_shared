import 'package:flutter/foundation.dart';

/// Copy for [DfAccountSettingsSection].
///
/// Defaults are English: a shared package must not impose a language. Pass a
/// localized instance to override.
@immutable
class DfAccountSettingsStrings {
  const DfAccountSettingsStrings({
    this.eyebrow = 'Settings',
    this.title = 'Account',
    this.signedInAs = 'Signed in as',
    this.contactSupport = 'Contact support',
    this.website = 'Website',
    this.privacyPolicy = 'Privacy policy',
    this.terms = 'Terms of use',
    this.signOut = 'Sign out',
    this.signOutConfirmTitle = 'Sign out?',
    this.signOutConfirmBody =
        'You will need to sign in again to reach your data on this device.',
    this.cancel = 'Cancel',
    this.deleteAccount = 'Delete account',
    this.keepAccount = 'Keep account',
    this.deleteConfirmTitle = 'Delete your account?',
    this.deleteConfirmBody =
        'This removes your account and everything in it, on every device. '
        'It cannot be undone.',
    this.deleteFailed = 'Could not delete the account. Please try again.',
    this.supportMailSubject = 'Support request',
    this.noMailApp = 'No mail app is set up on this device.',
    this.couldNotOpenLink = 'Could not open that link.',
    this.versionLabel = 'Version',
  });

  /// German strings.
  const DfAccountSettingsStrings.de({
    this.eyebrow = 'Einstellungen',
    this.title = 'Konto',
    this.signedInAs = 'Angemeldet als',
    this.contactSupport = 'Support kontaktieren',
    this.website = 'Website',
    this.privacyPolicy = 'Datenschutz',
    this.terms = 'Nutzungsbedingungen',
    this.signOut = 'Abmelden',
    this.signOutConfirmTitle = 'Abmelden?',
    this.signOutConfirmBody = 'Du musst dich auf diesem Gerät erneut anmelden, um wieder auf deine Daten zuzugreifen.',
    this.cancel = 'Abbrechen',
    this.deleteAccount = 'Konto löschen',
    this.keepAccount = 'Konto behalten',
    this.deleteConfirmTitle = 'Konto löschen?',
    this.deleteConfirmBody = 'Dadurch werden dein Konto und alle zugehörigen Daten auf allen Geräten entfernt. Das kann nicht rückgängig gemacht werden.',
    this.deleteFailed =
        'Das Konto konnte nicht gelöscht werden. Versuch es erneut.',
    this.supportMailSubject = 'Support-Anfrage',
    this.noMailApp = 'Auf diesem Gerät ist keine Mail-App eingerichtet.',
    this.couldNotOpenLink = 'Der Link konnte nicht geöffnet werden.',
    this.versionLabel = 'Version',
  });

  final String eyebrow;
  final String title;
  final String signedInAs;
  final String contactSupport;
  final String website;
  final String privacyPolicy;
  final String terms;

  final String signOut;
  final String signOutConfirmTitle;
  final String signOutConfirmBody;
  final String cancel;

  final String deleteAccount;

  /// The dismissive option in the delete dialog.
  ///
  /// Named for what it does rather than "Cancel": next to an irreversible
  /// action, the safe choice should say what it preserves.
  final String keepAccount;

  final String deleteConfirmTitle;
  final String deleteConfirmBody;
  final String deleteFailed;

  final String supportMailSubject;
  final String noMailApp;
  final String couldNotOpenLink;
  final String versionLabel;
}
