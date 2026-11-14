import 'package:df_settings/df_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('DfLegalLinksSection', () {
    testWidgets('legal links open through injectable launcher', (tester) async {
      const strings = DfSettingsStrings();
      Uri? launchedUri;

      Future<bool> fakeLauncher(Uri uri) async {
        launchedUri = uri;
        return true;
      }

      await tester.pumpWidget(
        _buildTestApp(
          DfLegalLinksSection(
            privacyPolicyUrl: 'https://example.com/privacy',
            termsOfServiceUrl: 'https://example.com/terms',
            launcher: fakeLauncher,
            showLicenses: false,
          ),
        ),
      );

      // Tap Privacy Policy
      await tester.tap(find.text(strings.privacyPolicy));
      await tester.pumpAndSettle();

      expect(launchedUri, Uri.parse('https://example.com/privacy'));

      // Tap Terms of Service
      await tester.tap(find.text(strings.termsOfService));
      await tester.pumpAndSettle();

      expect(launchedUri, Uri.parse('https://example.com/terms'));
    });

    testWidgets('shows snackbar error when launcher fails', (tester) async {
      const strings = DfSettingsStrings();

      await tester.pumpWidget(
        _buildTestApp(
          DfLegalLinksSection(
            privacyPolicyUrl: 'https://example.com/privacy',
            launcher: (_) async => false,
            showLicenses: false,
          ),
        ),
      );

      await tester.tap(find.text(strings.privacyPolicy));
      await tester.pumpAndSettle();

      expect(find.text(strings.couldNotOpenLink), findsOneWidget);
    });
  });

  group('DfDeleteAccountTile', () {
    testWidgets('delete-account requires confirmation before executing', (
      tester,
    ) async {
      const strings = DfSettingsStrings();
      var deleteCallCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          DfDeleteAccountTile(
            onDeleteAccount: () async {
              deleteCallCount++;
            },
          ),
        ),
      );

      // Tap the tile to trigger confirmation dialog
      await tester.tap(find.text(strings.deleteAccount));
      await tester.pumpAndSettle();

      // Verify confirmation dialog is visible
      expect(find.text(strings.deleteConfirmTitle), findsOneWidget);
      expect(find.text(strings.deleteConfirmBody), findsOneWidget);

      // Dismiss / Cancel deletion
      await tester.tap(find.text(strings.keepAccount));
      await tester.pumpAndSettle();

      // Verify onDeleteAccount was NOT called
      expect(deleteCallCount, 0);

      // Tap the tile again
      await tester.tap(find.text(strings.deleteAccount));
      await tester.pumpAndSettle();

      // Find all buttons with "Delete account" (tile and dialog button)
      final deleteButtons = find.text(strings.deleteAccount);
      expect(deleteButtons, findsNWidgets(2));

      // Tap the dialog confirmation button (the last one)
      await tester.tap(deleteButtons.last);
      await tester.pumpAndSettle();

      // Verify onDeleteAccount WAS called exactly once
      expect(deleteCallCount, 1);
    });
  });

  group('DfThemeModeTile', () {
    testWidgets('opens selection dialog and triggers onModeChanged', (
      tester,
    ) async {
      const strings = DfSettingsStrings();
      ThemeMode? updatedMode;

      await tester.pumpWidget(
        _buildTestApp(
          DfThemeModeTile(
            currentMode: ThemeMode.system,
            onModeChanged: (mode) {
              updatedMode = mode;
            },
          ),
        ),
      );

      // Verify current mode label is shown
      expect(find.text(strings.themeSystem), findsOneWidget);

      // Tap the tile to open dialog
      await tester.tap(find.text(strings.themeTitle));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text(strings.themeDialogTitle), findsOneWidget);

      // Select Dark mode
      await tester.tap(find.text(strings.themeDark));
      await tester.pumpAndSettle();

      // Verify callback was invoked with Dark mode
      expect(updatedMode, ThemeMode.dark);
    });
  });
}
