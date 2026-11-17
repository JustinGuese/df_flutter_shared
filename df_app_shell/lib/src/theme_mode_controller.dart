import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for [SharedPreferences].
///
/// Apps should override this at the root [ProviderScope] in `main()`:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(
///   ProviderScope(
///     overrides: [
///       sharedPreferencesProvider.overrideWithValue(prefs),
///     ],
///     child: const MyApp(),
///   ),
/// );
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider was not overridden. '
    'Override it in ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)])',
  );
});

/// Persists and controls the application's [ThemeMode].
///
/// Reads from and writes to [SharedPreferences] using [storageKey].
class DfThemeModeController extends Notifier<ThemeMode> {
  /// Default preferences key for the theme mode.
  static const String defaultStorageKey = 'df_theme_mode';

  /// Key in [SharedPreferences] used to persist the theme mode.
  final String storageKey;

  DfThemeModeController({this.storageKey = defaultStorageKey});

  SharedPreferences? _prefs;

  @override
  ThemeMode build() {
    final prefs = _safeGetPrefs();
    _prefs = prefs;
    if (prefs == null) {
      unawaited(_asyncInit());
      return ThemeMode.system;
    }
    return _loadFromPrefs(prefs);
  }

  SharedPreferences? _safeGetPrefs() {
    try {
      return ref.watch(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }

  Future<void> _asyncInit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      final loaded = _loadFromPrefs(prefs);
      if (state != loaded) {
        state = loaded;
      }
    } catch (_) {
      // Ignored if SharedPreferences is unavailable.
    }
  }

  ThemeMode _loadFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(storageKey);
    if (raw == null) return ThemeMode.system;
    for (final mode in ThemeMode.values) {
      if (mode.name == raw) return mode;
    }
    return ThemeMode.system;
  }

  /// Sets the current theme mode and persists it to preferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs =
        _prefs ?? _safeGetPrefs() ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(storageKey, mode.name);
  }

  /// Convenience method to set theme mode to [ThemeMode.light].
  Future<void> setLight() => setThemeMode(ThemeMode.light);

  /// Convenience method to set theme mode to [ThemeMode.dark].
  Future<void> setDark() => setThemeMode(ThemeMode.dark);

  /// Convenience method to set theme mode to [ThemeMode.system].
  Future<void> setSystem() => setThemeMode(ThemeMode.system);

  /// Cycles between system, light, and dark modes (or toggles light/dark).
  Future<void> toggle() {
    final next = switch (state) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.system => ThemeMode.dark,
    };
    return setThemeMode(next);
  }
}

/// Provider managing the active [ThemeMode].
final dfThemeModeProvider = NotifierProvider<DfThemeModeController, ThemeMode>(
  DfThemeModeController.new,
);

/// Alias for [dfThemeModeProvider].
final dfThemeModeControllerProvider = dfThemeModeProvider;
