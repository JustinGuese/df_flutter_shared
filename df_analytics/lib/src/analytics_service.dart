import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'df_firebase_meta_sink.dart';

/// Service for logging analytics events using Firebase Analytics.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  /// Connects Firebase Analytics and installs [DfFirebaseMetaSink] as
  /// `DfAnalyticsCore.sink`, so the events shared packages emit (onboarding,
  /// sign-in, consent, screen views) start flowing without further wiring.
  ///
  /// [metaConversions] names the app's events that also count as Meta
  /// conversions, on top of [dfDefaultMetaConversions]. [sendUserId] sends the
  /// signed-in account id to GA4 (never to Meta).
  void initialize({
    Map<String, DfMetaConversion> metaConversions = const {},
    bool sendUserId = false,
  }) {
    DfAnalyticsCore.sink = DfFirebaseMetaSink(
      metaConversions: metaConversions,
      sendUserId: sendUserId,
    );
    try {
      _analytics = FirebaseAnalytics.instance;
      if (kDebugMode) {
        debugPrint('AnalyticsService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize AnalyticsService: $e');
      }
    }
  }

  void logAppOpen() {
    _analytics?.logAppOpen();
  }

  /// Log a custom event with optional parameters.
  void logEvent({required String name, Map<String, Object>? parameters}) {
    _analytics?.logEvent(name: name, parameters: parameters);
  }

  /// Log an event and optionally invoke a Meta tracking callback.
  void logEventWithMeta({
    required String name,
    Map<String, Object>? parameters,
    VoidCallback? onMeta,
  }) {
    logEvent(name: name, parameters: parameters);
    try {
      onMeta?.call();
    } catch (_) {
      // Meta tracking failure must not affect Firebase or app flow
    }
  }

  void setUserProperty({required String name, required String? value}) {
    _analytics?.setUserProperty(name: name, value: value);
  }

  void logInstallation({String? platform}) {
    logEvent(
      name: 'app_install',
      parameters: platform != null ? {'platform': platform} : null,
    );
  }
}
