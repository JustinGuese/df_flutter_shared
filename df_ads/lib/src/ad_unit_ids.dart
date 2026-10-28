import 'package:flutter/foundation.dart';

/// AdMob ad unit IDs container with Google's public test IDs built in.
///
/// In debug mode or on non-mobile platforms, [banner] and [interstitial]
/// return Google test unit IDs so development and testing never touch real ads.
/// In release mode on Android and iOS, they return the provided production IDs.
@immutable
class DfAdUnitIds {
  const DfAdUnitIds({
    this.androidBanner = testAndroidBanner,
    this.iosBanner = testIosBanner,
    this.androidInterstitial = testAndroidInterstitial,
    this.iosInterstitial = testIosInterstitial,
    this.isReleaseOverride,
  });

  /// Google public test banner ad unit ID for Android.
  static const String testAndroidBanner =
      'ca-app-pub-3940256099942544/6300978111';

  /// Google public test banner ad unit ID for iOS.
  static const String testIosBanner = 'ca-app-pub-3940256099942544/2934735716';

  /// Google public test interstitial ad unit ID for Android.
  static const String testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  /// Google public test interstitial ad unit ID for iOS.
  static const String testIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  /// Production ad unit ID for Android banners.
  final String androidBanner;

  /// Production ad unit ID for iOS banners.
  final String iosBanner;

  /// Production ad unit ID for Android interstitials.
  final String androidInterstitial;

  /// Production ad unit ID for iOS interstitials.
  final String iosInterstitial;

  /// Optional override for release mode check, primarily for testing.
  @visibleForTesting
  final bool? isReleaseOverride;

  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _isReal =>
      (isReleaseOverride ?? kReleaseMode) && (_isAndroid || _isIos);

  /// Banner ad unit ID.
  ///
  /// Returns Google's test banner ID in debug mode, or the configured
  /// platform-specific production ID in release mode.
  String get banner {
    if (!_isReal) {
      return _isIos ? testIosBanner : testAndroidBanner;
    }
    return _isIos ? iosBanner : androidBanner;
  }

  /// Interstitial ad unit ID.
  ///
  /// Returns Google's test interstitial ID in debug mode, or the configured
  /// platform-specific production ID in release mode.
  String get interstitial {
    if (!_isReal) {
      return _isIos ? testIosInterstitial : testAndroidInterstitial;
    }
    return _isIos ? iosInterstitial : androidInterstitial;
  }
}
