import 'package:flutter/foundation.dart';

/// Configuration for analytics (SharedPreferences keys, etc.).
@immutable
class AnalyticsConfig {
  const AnalyticsConfig({
    this.installationTrackedKey = 'installation_tracked',
    this.consentGivenKey = 'tracking_consent_given',
  });

  final String installationTrackedKey;
  final String consentGivenKey;
}
