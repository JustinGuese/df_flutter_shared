import 'package:flutter/material.dart' show TimeOfDay;
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted on/off + time-of-day for a single "remind me daily at HH:MM"
/// toggle — the settings-screen pattern behind PsychDiary's diary reminder
/// (enable switch + time picker, surviving app restarts).
///
/// This only stores the toggle state; actually (re)scheduling the
/// notification with a [DfReminderService] is the caller's job, typically
/// right after [save] and once more on app start.
///
/// [storeKey] namespaces the three preference keys, so an app with more than
/// one toggleable reminder (e.g. "diary" and "vitals") doesn't collide.
class DfReminderPreferences {
  const DfReminderPreferences({required this.storeKey});

  final String storeKey;

  String get _enabledKey => '${storeKey}_df_reminder_enabled';
  String get _hourKey => '${storeKey}_df_reminder_hour';
  String get _minuteKey => '${storeKey}_df_reminder_minute';

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// The saved time, or `null` when disabled or never set.
  Future<TimeOfDay?> getTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_enabledKey) ?? false)) return null;
    final hour = prefs.getInt(_hourKey);
    final minute = prefs.getInt(_minuteKey);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Turns the reminder on and stores [hour]:[minute].
  Future<void> save({required int hour, required int minute}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);
  }

  /// Turns the reminder off. The stored time is left in place so re-enabling
  /// can default back to it.
  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
  }
}
