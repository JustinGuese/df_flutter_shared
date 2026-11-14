import 'package:df_firebase_auth/df_firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfAccountSettingsStrings.de', () {
    test('has valid non-empty German strings', () {
      const de = DfAccountSettingsStrings.de();
      expect(de.title, 'Konto');
      expect(de.eyebrow, 'Einstellungen');
      expect(de.signOut, 'Abmelden');
      expect(de.signOutConfirmTitle, 'Abmelden?');
      expect(de.deleteAccount, 'Konto löschen');
      expect(de.keepAccount, 'Konto behalten');
      expect(de.cancel, 'Abbrechen');
      expect(de.contactSupport, 'Support kontaktieren');
      expect(de.privacyPolicy, 'Datenschutz');
      expect(de.terms, 'Nutzungsbedingungen');
      expect(de.deleteConfirmTitle, 'Konto löschen?');
      expect(de.deleteConfirmBody.isNotEmpty, isTrue);
      expect(de.signOutConfirmBody.isNotEmpty, isTrue);
      expect(de.deleteFailed.isNotEmpty, isTrue);
      expect(de.noMailApp.isNotEmpty, isTrue);
      expect(de.couldNotOpenLink.isNotEmpty, isTrue);
      expect(de.versionLabel, 'Version');
    });

    test('allows overriding individual fields', () {
      const custom = DfAccountSettingsStrings.de(title: 'Mein Profil');
      expect(custom.title, 'Mein Profil');
      expect(custom.signOut, 'Abmelden');
    });
  });

  group('DfLoginStrings.de and DfRegisterStrings.de', () {
    test(
      'DfLoginStrings.de provides localized German copy and token substitution',
      () {
        const de = DfLoginStrings.de();
        expect(de.welcomeTitle, 'Willkommen zurück');
        expect(de.signInButton, 'Anmelden');
        expect(de.emailLabel, 'E-Mail');
        expect(de.passwordLabel, 'Passwort');
        expect(de.forgotPassword, 'Passwort vergessen?');
        expect(de.noAccount, 'Noch kein Konto? Registrieren');
        expect(de.orDivider, 'ODER');
        expect(de.googleButton, 'Mit Google anmelden');

        final filledSubtitle = DfLoginStrings.fill(de.subtitle, {
          'appName': 'TestApp',
        });
        expect(filledSubtitle, 'Melde dich bei deinem TestApp-Workspace an');

        final filledSent = DfLoginStrings.fill(de.resetSent, {
          'email': 'test@example.com',
        });
        expect(
          filledSent,
          'E-Mail zum Zurücksetzen wurde an test@example.com gesendet. Prüfe dein Postfach.',
        );
      },
    );

    test('DfRegisterStrings.de provides localized German copy', () {
      const de = DfRegisterStrings.de();
      expect(de.title, 'Konto erstellen');
      expect(de.signUpButton, 'Registrieren');
      expect(de.confirmPasswordLabel, 'Passwort bestätigen');
      expect(de.passwordMismatch, 'Die Passwörter stimmen nicht überein');
      expect(de.haveAccount, 'Bereits ein Konto? Anmelden');
      expect(de.googleButton, 'Mit Google registrieren');
    });
  });

  group('DfSignInSheetStrings.de', () {
    test('provides German strings and formats error messages safely', () {
      const de = DfSignInSheetStrings.de();
      expect(de.title, 'Fortschritt geräteübergreifend speichern');
      expect(de.googleButton, 'Weiter mit Google');
      expect(de.appleButton, 'Weiter mit Apple');
      expect(de.notNowButton, 'Nicht jetzt');

      final googleError = de.fillGoogleFailed('network_timeout');
      expect(googleError, 'Google-Anmeldung fehlgeschlagen: network_timeout');

      final appleError = de.fillAppleFailed('cancelled');
      expect(appleError, 'Apple-Anmeldung fehlgeschlagen: cancelled');
    });

    test('copyWith preserves unchanged fields', () {
      const de = DfSignInSheetStrings.de();
      final updated = de.copyWith(notNowButton: 'Später');
      expect(updated.notNowButton, 'Später');
      expect(updated.title, de.title);
      expect(updated.googleButton, de.googleButton);
    });
  });
}
