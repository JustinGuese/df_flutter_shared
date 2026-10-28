import 'package:shared_preferences/shared_preferences.dart';

/// Persistent cooldown gate backed by [SharedPreferences].
///
/// Records an ISO 8601 timestamp at [key]. [isReady] returns true if the key
/// has never been set or if at least [duration] has passed since the last [mark].
class DfCooldown {
  const DfCooldown({required this.key, required this.duration});

  /// SharedPreferences key where the ISO 8601 timestamp is persisted.
  final String key;

  /// Cooldown duration that must elapse before [isReady] returns `true`.
  final Duration duration;

  /// Returns `true` if at least [duration] has elapsed since the last [mark],
  /// or if [mark] was never called.
  Future<bool> isReady({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().difference(last) >= duration;
  }

  /// Records [now] (defaults to `DateTime.now()`) in [SharedPreferences] at [key].
  Future<void> mark({SharedPreferences? prefs, DateTime? now}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final timestamp = (now ?? DateTime.now()).toIso8601String();
    await p.setString(key, timestamp);
  }

  /// Clears the recorded timestamp, resetting the cooldown.
  Future<void> reset({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.remove(key);
  }

  /// Returns the last recorded timestamp, or `null` if not set or unparseable.
  Future<DateTime?> lastMarked({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
