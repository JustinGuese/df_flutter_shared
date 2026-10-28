import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_factory.dart';
import 'ad_unit_ids.dart';
import 'ads_strings.dart';

/// Global configuration and lifecycle management for ads.
class DfAds {
  DfAds._();

  static DfAdUnitIds _ids = const DfAdUnitIds();
  static DfAdFactory _factory = const DfPlainAdFactory();
  static DfAdsStrings _strings = const DfAdsStrings();
  static bool _initialized = false;

  /// Visible for unit testing to simulate web environment.
  @visibleForTesting
  static bool? debugIsWebOverride;

  /// Whether current execution should be treated as web (respects [debugIsWebOverride]).
  static bool get isPlatformWeb => debugIsWebOverride ?? kIsWeb;

  /// Returns the configured ad unit ids.
  static DfAdUnitIds get ids => _ids;

  /// Returns the configured ad factory.
  static DfAdFactory get factory => _factory;

  /// Returns the configured ads strings.
  static DfAdsStrings get strings => _strings;

  /// Whether [initialize] has completed.
  static bool get isInitialized => _initialized;

  /// Configures global ad unit ids, factory, and optional strings.
  static void configure({
    DfAdUnitIds? ids,
    DfAdFactory? factory,
    DfAdsStrings? strings,
  }) {
    if (ids != null) _ids = ids;
    if (factory != null) _factory = factory;
    if (strings != null) _strings = strings;
  }

  /// Initializes the underlying Google Mobile Ads SDK.
  ///
  /// This is a no-op on web platforms.
  static Future<InitializationStatus?> initialize() async {
    if (isPlatformWeb) return null;
    _initialized = true;
    return MobileAds.instance.initialize();
  }

  /// Resets configuration to defaults for tests.
  @visibleForTesting
  static void resetForTesting() {
    _ids = const DfAdUnitIds();
    _factory = const DfPlainAdFactory();
    _strings = const DfAdsStrings();
    _initialized = false;
    debugIsWebOverride = null;
  }
}
