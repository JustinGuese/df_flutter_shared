import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Factory interface for creating and loading AdMob ads.
///
/// Apps can provide a custom implementation (e.g. `DfRevenueCatAdFactory`
/// from `df_ads_revenuecat`) to intercept banner creation and interstitial
/// loads for revenue tracking or analytics.
abstract class DfAdFactory {
  const DfAdFactory();

  /// Creates a [BannerAd].
  BannerAd createBanner({
    required String adUnitId,
    required AdSize size,
    AdRequest request = const AdRequest(),
    String? placement,
    BannerAdListener? listener,
  });

  /// Loads an [InterstitialAd].
  Future<void> loadInterstitial({
    required String adUnitId,
    AdRequest request = const AdRequest(),
    String? placement,
    required InterstitialAdLoadCallback adLoadCallback,
  });

  /// Shows the given [InterstitialAd].
  void showInterstitial(InterstitialAd ad);
}

/// Default ad factory using plain [google_mobile_ads] APIs.
class DfPlainAdFactory implements DfAdFactory {
  const DfPlainAdFactory();

  @override
  BannerAd createBanner({
    required String adUnitId,
    required AdSize size,
    AdRequest request = const AdRequest(),
    String? placement,
    BannerAdListener? listener,
  }) {
    return BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: request,
      listener: listener ?? const BannerAdListener(),
    );
  }

  @override
  Future<void> loadInterstitial({
    required String adUnitId,
    AdRequest request = const AdRequest(),
    String? placement,
    required InterstitialAdLoadCallback adLoadCallback,
  }) {
    return InterstitialAd.load(
      adUnitId: adUnitId,
      request: request,
      adLoadCallback: adLoadCallback,
    );
  }

  @override
  void showInterstitial(InterstitialAd ad) {
    ad.show();
  }
}
