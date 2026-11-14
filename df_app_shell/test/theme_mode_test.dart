import 'package:df_app_shell/df_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DfThemeModeController', () {
    test('persists and restores theme mode', () async {
      SharedPreferences.setMockInitialValues({
        DfThemeModeController.defaultStorageKey: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();

      final container1 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container1.dispose);

      // Restores persisted dark theme
      expect(container1.read(dfThemeModeProvider), ThemeMode.dark);

      // Change to light theme
      await container1.read(dfThemeModeProvider.notifier).setLight();
      expect(container1.read(dfThemeModeProvider), ThemeMode.light);
      expect(prefs.getString(DfThemeModeController.defaultStorageKey), 'light');

      // Fresh container restores updated light theme
      final container2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container2.dispose);
      expect(container2.read(dfThemeModeProvider), ThemeMode.light);
    });

    test('recovers gracefully from corrupt preferences value', () async {
      SharedPreferences.setMockInitialValues({
        DfThemeModeController.defaultStorageKey: 'invalid_mode_value',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      // Falls back to system default instead of crashing
      expect(container.read(dfThemeModeProvider), ThemeMode.system);
    });
  });

  group('DfLocaleController', () {
    test('persists, restores, and clears locale', () async {
      SharedPreferences.setMockInitialValues({
        DfLocaleController.defaultStorageKey: 'en_US',
      });
      final prefs = await SharedPreferences.getInstance();

      final container1 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container1.dispose);

      expect(container1.read(dfLocaleProvider), const Locale('en', 'US'));

      // Change to German
      await container1
          .read(dfLocaleProvider.notifier)
          .setLocale(const Locale('de'));
      expect(container1.read(dfLocaleProvider), const Locale('de'));
      expect(prefs.getString(DfLocaleController.defaultStorageKey), 'de');

      // Clear back to system default
      await container1.read(dfLocaleProvider.notifier).clearLocale();
      expect(container1.read(dfLocaleProvider), isNull);
      expect(prefs.containsKey(DfLocaleController.defaultStorageKey), isFalse);
    });
  });
}
