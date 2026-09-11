import 'package:flutter/foundation.dart';

import 'df_analytics_sink.dart';

/// The one place shared packages and app code report analytics through.
///
/// ```dart
/// DfAnalyticsCore.track(DfEvents.signUp, {DfEventParams.method: 'google'});
/// ```
///
/// Every call is fail-soft — a broken sink drops the event, it never breaks the
/// flow that reported it. Names and parameters are checked against GA4's rules
/// first: an invalid name asserts in debug (so a typo surfaces while developing)
/// and is dropped in release.
abstract final class DfAnalyticsCore {
  static DfAnalyticsSink _sink = const _UnwiredSink();
  static String? _lastScreen;

  /// The sink events are forwarded to. `df_analytics` installs its Firebase +
  /// Meta sink from `AnalyticsService.initialize()`; set this directly only for
  /// a custom sink. Set it before `runApp`.
  static DfAnalyticsSink get sink => _sink;
  static set sink(DfAnalyticsSink value) {
    _sink = value;
    _lastScreen = null;
  }

  /// False until an app installs a sink. Events reported before then are
  /// dropped, with a warning in debug builds.
  static bool get isWired => _sink is! _UnwiredSink;

  /// Reports [name] with [parameters]. Null values are dropped, bools become
  /// `1`/`0` (Firebase rejects bools), strings are cut to GA4's 100 characters.
  static void track(String name, [Map<String, Object?> parameters = const {}]) {
    assert(isValidEventName(name), 'Invalid analytics event name: "$name"');
    if (!isValidEventName(name)) return;
    final clean = normaliseParameters(parameters);
    if (kDebugMode) debugPrint('[analytics] $name $clean');
    _guard(name, () => _sink.track(name, clean));
  }

  /// Reports that [screenName] is now on screen. A repeat of the screen that
  /// was reported last is ignored, so a route observer and app code that both
  /// report the same screen (or a dialog closing over it) count it once.
  static void screenView(String screenName, {String? screenClass}) {
    if (screenName.isEmpty || screenName == _lastScreen) return;
    _lastScreen = screenName;
    final name = _truncate(screenName);
    if (kDebugMode) debugPrint('[analytics] screen_view $name');
    _guard(
      'screen_view',
      () => _sink.screenView(name, screenClass: screenClass),
    );
  }

  /// Reports the signed-in account id, or null after sign-out.
  static void identify(String? userId) {
    _guard('identify', () => _sink.identify(userId));
  }

  static final RegExp _namePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
  static const _reservedPrefixes = ['firebase_', 'google_', 'ga_'];
  static const _maxNameLength = 40;
  static const _maxParameters = 25;
  static const _maxValueLength = 100;

  /// Whether [name] is accepted by GA4 as an event or parameter name.
  static bool isValidEventName(String name) =>
      name.length <= _maxNameLength &&
      _namePattern.hasMatch(name) &&
      !_reservedPrefixes.any(name.startsWith);

  /// [parameters] reduced to what Firebase accepts. Invalid keys are dropped
  /// (asserting in debug) rather than failing the whole event.
  @visibleForTesting
  static Map<String, Object> normaliseParameters(
    Map<String, Object?> parameters,
  ) {
    final result = <String, Object>{};
    for (final MapEntry(:key, :value) in parameters.entries) {
      assert(isValidEventName(key), 'Invalid analytics parameter name: "$key"');
      if (value == null || !isValidEventName(key)) continue;
      if (result.length == _maxParameters) break;
      result[key] = switch (value) {
        bool() => value ? 1 : 0,
        num() => value,
        _ => _truncate(value.toString()),
      };
    }
    return result;
  }

  /// Restores the unwired state between tests.
  @visibleForTesting
  static void debugReset() {
    _sink = const _UnwiredSink();
    _lastScreen = null;
    _UnwiredSink._warned = false;
  }

  static String _truncate(String value) => value.length <= _maxValueLength
      ? value
      : value.substring(0, _maxValueLength);

  static void _guard(String label, void Function() op) {
    try {
      op();
    } catch (e) {
      if (kDebugMode) debugPrint('[analytics] $label failed: $e');
    }
  }
}

/// Drops everything — but says so once, loudly, in debug. A package that
/// reports into nothing looks exactly like one that works, so an app that
/// forgot to install a sink must not be quiet about it.
class _UnwiredSink implements DfAnalyticsSink {
  const _UnwiredSink();

  static bool _warned = false;

  void _warn() {
    if (_warned || !kDebugMode) return;
    _warned = true;
    debugPrint(
      '[analytics] WARNING: events are being dropped — no DfAnalyticsSink is '
      'installed. Call AnalyticsService.instance.initialize() (df_analytics) '
      'or set DfAnalyticsCore.sink before runApp.',
    );
  }

  @override
  void track(String name, Map<String, Object> parameters) => _warn();

  @override
  void screenView(String screenName, {String? screenClass}) => _warn();

  @override
  void identify(String? userId) {}
}
