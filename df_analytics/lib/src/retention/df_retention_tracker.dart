import 'package:shared_preferences/shared_preferences.dart';

import '../analytics_service.dart';
import '../meta/meta_conversion_tracking.dart';

/// How retention milestones are named and when they fire.
class DfRetentionConfig {
  const DfRetentionConfig({
    this.keyPrefix = 'df_retention',
    this.milestoneDays = const [1, 2, 3, 7, 14, 30],
    this.eventNamePrefix = 'Retention_D',
    this.maxRetainedDays = 400,
  });

  /// Namespaces every SharedPreferences key this tracker writes.
  final String keyPrefix;

  /// Days since first open at which to report a milestone, each fired at most
  /// once per install.
  final List<int> milestoneDays;

  /// Prepended to the day number to form the event name — `1` becomes
  /// `Retention_D1` by default.
  final String eventNamePrefix;

  /// Upper bound on remembered active days, so the stored list cannot grow
  /// without limit over an install's lifetime. Only affects [currentStreak]
  /// and [activeDayCount] for users active longer than this many days.
  final int maxRetainedDays;
}

/// Tracks how long a user keeps coming back, and reports the milestones to
/// Firebase and Meta.
///
/// Retention is the signal that separates a real user from an install that
/// never opened the app twice — ad platforms cannot optimise for it unless the
/// app says so explicitly.
///
/// Deliberately generic: it stores day stamps and counters under caller-named
/// keys and knows nothing about what the app does.
class DfRetentionTracker {
  DfRetentionTracker._();

  static final DfRetentionTracker instance = DfRetentionTracker._();

  /// Overridable so tests can advance the clock without waiting.
  DateTime Function() now = DateTime.now;

  /// Records today as an active day and reports any day-N milestone that has
  /// been reached but not yet reported.
  ///
  /// Safe — and intended — to call on every app open and resume: each
  /// milestone fires at most once per install.
  ///
  /// On iOS, call this *after* the ATT prompt has resolved; events reported
  /// before then are not attributable to a campaign.
  Future<void> recordAppOpen({
    DfRetentionConfig config = const DfRetentionConfig(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dayStamp(now());

    final firstOpen = prefs.getString(_firstOpenKey(config)) ?? today;
    if (prefs.getString(_firstOpenKey(config)) == null) {
      await prefs.setString(_firstOpenKey(config), today);
    }

    final activeDays = prefs.getStringList(_activeDaysKey(config)) ?? <String>[];
    if (!activeDays.contains(today)) {
      activeDays
        ..add(today)
        ..sort();
      // Drop the oldest entries rather than the newest: a streak is measured
      // backwards from today, so recent days are the ones that matter.
      final trimmed =
          activeDays.length > config.maxRetainedDays
              ? activeDays.sublist(activeDays.length - config.maxRetainedDays)
              : activeDays;
      await prefs.setStringList(_activeDaysKey(config), trimmed);
    }

    final elapsed = _daysBetween(firstOpen, today);
    for (final day in config.milestoneDays) {
      if (day <= elapsed) {
        await _fireOnce('${config.eventNamePrefix}$day', config, prefs);
      }
    }
  }

  /// Counts occurrences of [actionKey] and reports `${eventName}_$n` the first
  /// time each threshold in [milestones] is reached.
  ///
  /// Call once per occurrence of the action. The app names both the counter
  /// and the event, so this stays free of any product's vocabulary.
  Future<void> recordMilestoneAction({
    required String actionKey,
    required List<int> milestones,
    required String eventName,
    DfRetentionConfig config = const DfRetentionConfig(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${config.keyPrefix}_count_$actionKey';
    final count = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, count);

    if (milestones.contains(count)) {
      await _fireOnce('${eventName}_$count', config, prefs);
    }
  }

  /// The day the app was first opened, or null before [recordAppOpen] has run.
  Future<DateTime?> firstOpenDate({
    DfRetentionConfig config = const DfRetentionConfig(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stamp = prefs.getString(_firstOpenKey(config));
    return stamp == null ? null : DateTime.parse(stamp);
  }

  /// How many distinct days the app has been opened on.
  Future<int> activeDayCount({
    DfRetentionConfig config = const DfRetentionConfig(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_activeDaysKey(config)) ?? const <String>[])
        .length;
  }

  /// Consecutive active days ending today, or ending yesterday when the app
  /// has not been opened yet today — so a streak is not reported as broken
  /// before the user has had the chance to open the app.
  Future<int> currentStreak({
    DfRetentionConfig config = const DfRetentionConfig(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final activeDays =
        (prefs.getStringList(_activeDaysKey(config)) ?? const <String>[])
            .toSet();
    if (activeDays.isEmpty) return 0;

    final today = _dayStamp(now());
    var cursor = activeDays.contains(today) ? today : _shift(today, -1);
    if (!activeDays.contains(cursor)) return 0;

    var streak = 0;
    while (activeDays.contains(cursor)) {
      streak++;
      cursor = _shift(cursor, -1);
    }
    return streak;
  }

  /// Clears every key this tracker owns. Intended for tests and for a
  /// "delete my data" path.
  Future<void> reset({
    DfRetentionConfig config = const DfRetentionConfig(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final owned =
        prefs
            .getKeys()
            .where((key) => key.startsWith('${config.keyPrefix}_'))
            .toList();
    for (final key in owned) {
      await prefs.remove(key);
    }
  }

  /// Reports [eventName] to Firebase and Meta unless it has fired before.
  Future<void> _fireOnce(
    String eventName,
    DfRetentionConfig config,
    SharedPreferences prefs,
  ) async {
    final firedKey = _firedKey(config);
    final fired = prefs.getStringList(firedKey) ?? <String>[];
    if (fired.contains(eventName)) return;

    await prefs.setStringList(firedKey, [...fired, eventName]);

    AnalyticsService.instance.logEventWithMeta(
      name: _firebaseEventName(eventName),
      onMeta: () => trackMetaCustomConversion(eventName),
    );
  }

  String _firstOpenKey(DfRetentionConfig c) => '${c.keyPrefix}_first_open';
  String _activeDaysKey(DfRetentionConfig c) => '${c.keyPrefix}_active_days';
  String _firedKey(DfRetentionConfig c) => '${c.keyPrefix}_fired';
}

/// Firebase and Meta disagree on event-name rules: Firebase allows only
/// letters, digits and underscores and wants snake_case, while Meta accepts
/// spaces and hyphens. The Meta name is authoritative; this derives a legal
/// Firebase name from it so the same milestone is recognisable in both tools.
String _firebaseEventName(String metaEventName) {
  final sanitised = metaEventName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
      .replaceAll(RegExp(r'_+'), '_');
  final leadingTrimmed = sanitised.replaceFirst(RegExp(r'^_+'), '');
  // Firebase requires a letter first and caps names at 40 characters.
  final prefixed =
      RegExp(r'^[a-z]').hasMatch(leadingTrimmed)
          ? leadingTrimmed
          : 'e_$leadingTrimmed';
  return prefixed.length <= 40 ? prefixed : prefixed.substring(0, 40);
}

/// `YYYY-MM-DD` in local time. Day stamps rather than DateTimes because
/// retention is a calendar-day question: two opens 20 hours apart may or may
/// not be two active days, and only the calendar can say.
String _dayStamp(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

/// Whole calendar days from [from] to [to], both `YYYY-MM-DD`.
int _daysBetween(String from, String to) =>
    DateTime.parse(to).difference(DateTime.parse(from)).inDays;

/// [stamp] moved by [days], staying on calendar days across DST boundaries.
String _shift(String stamp, int days) {
  final date = DateTime.parse(stamp);
  return _dayStamp(DateTime(date.year, date.month, date.day + days));
}
