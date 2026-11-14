import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_mode_controller.dart';

/// Persists and controls the user's selected [Locale].
///
/// A `null` state indicates following the system locale.
class DfLocaleController extends Notifier<Locale?> {
  /// Default preferences key for the locale.
  static const String defaultStorageKey = 'df_locale';

  /// Key in [SharedPreferences] used to persist the locale code.
  final String storageKey;

  DfLocaleController({this.storageKey = defaultStorageKey});

  SharedPreferences? _prefs;

  @override
  Locale? build() {
    final prefs = _safeGetPrefs();
    _prefs = prefs;
    if (prefs == null) {
      unawaited(_asyncInit());
      return null;
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

  Locale? _loadFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(storageKey);
    return parseLocale(raw);
  }

  /// Sets the active locale and stores it in [SharedPreferences].
  ///
  /// Passing `null` removes the key from preferences, falling back to system.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs =
        _prefs ?? _safeGetPrefs() ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final serialized = serializeLocale(locale);
    if (serialized == null) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, serialized);
    }
  }

  /// Clears user-selected locale, returning to system default.
  Future<void> clearLocale() => setLocale(null);

  /// Parses a string representation (e.g. `'de'`, `'en_US'`, `'en-US'`) into a [Locale].
  static Locale? parseLocale(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    final parts = trimmed.split(RegExp(r'[-_]'));
    if (parts.isEmpty) return null;
    if (parts.length == 1) {
      return Locale(parts[0]);
    }
    return Locale(parts[0], parts[1]);
  }

  /// Serializes a [Locale] to a storage string (e.g. `'de'` or `'en_US'`).
  static String? serializeLocale(Locale? locale) {
    if (locale == null) return null;
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}

/// Provider managing the active [Locale] or `null` for system default.
final dfLocaleProvider = NotifierProvider<DfLocaleController, Locale?>(
  DfLocaleController.new,
);

/// Alias for [dfLocaleProvider].
final dfLocaleControllerProvider = dfLocaleProvider;
