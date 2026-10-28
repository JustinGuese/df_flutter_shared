import 'package:flutter/foundation.dart';

/// Configuration for [DfRevenueCat].
///
/// Encapsulates API keys, entitlement IDs, and placement settings for
/// RevenueCat offerings and exit offers.
@immutable
class DfRevenueCatConfig {
  const DfRevenueCatConfig({
    required this.iosApiKey,
    required this.androidApiKey,
    required this.entitlementId,
    this.defaultOfferingId = 'default',
    this.exitOfferPlacement = 'exit_offer',
    this.exitOfferAfter = const {},
    this.exitOfferShownKey = 'exit_offer_shown',
  });

  /// RevenueCat public SDK key for iOS.
  final String iosApiKey;

  /// RevenueCat public SDK key for Android.
  final String androidApiKey;

  /// The entitlement ID gating Pro access in RevenueCat.
  final String entitlementId;

  /// Offering ID to fall back to if placement-targeted lookup returns null.
  final String defaultOfferingId;

  /// Placement identifier used for the exit offer paywall.
  final String exitOfferPlacement;

  /// Placements that trigger an exit offer if the user dismisses the paywall.
  final Set<String> exitOfferAfter;

  /// SharedPreferences key recording whether the exit offer was already shown.
  final String exitOfferShownKey;

  /// The active API key based on the current platform.
  String get apiKey {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosApiKey;
    }
    return androidApiKey;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DfRevenueCatConfig &&
          runtimeType == other.runtimeType &&
          iosApiKey == other.iosApiKey &&
          androidApiKey == other.androidApiKey &&
          entitlementId == other.entitlementId &&
          defaultOfferingId == other.defaultOfferingId &&
          exitOfferPlacement == other.exitOfferPlacement &&
          setEquals(exitOfferAfter, other.exitOfferAfter) &&
          exitOfferShownKey == other.exitOfferShownKey);

  @override
  int get hashCode => Object.hash(
    iosApiKey,
    androidApiKey,
    entitlementId,
    defaultOfferingId,
    exitOfferPlacement,
    Object.hashAllUnordered(exitOfferAfter),
    exitOfferShownKey,
  );

  @override
  String toString() =>
      'DfRevenueCatConfig(entitlementId: $entitlementId, exitOfferPlacement: $exitOfferPlacement)';
}
