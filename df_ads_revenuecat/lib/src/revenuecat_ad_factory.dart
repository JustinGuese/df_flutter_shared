import 'dart:async';

import 'package:df_ads/df_ads.dart';
import 'package:purchases_admob_flutter/purchases_admob_flutter.dart';

/// Implementation of [DfAdFactory] that routes ad creation and interstitial
/// loading through RevenueCat's [RevenueCatAdMob] adapter for automatic
/// impression and revenue tracking.
class DfRevenueCatAdFactory implements DfAdFactory {
  /// Creates a [DfRevenueCatAdFactory].
  const DfRevenueCatAdFactory();

  @override
  BannerAd createBanner({
    required String adUnitId,
    required AdSize size,
    AdRequest request = const AdRequest(),
    String? placement,
    BannerAdListener? listener,
  }) {
    return RevenueCatAdMob.createBannerAd(
      adUnitId: adUnitId,
      size: size,
      request: request,
      placement: placement,
      listener: listener,
    );
  }

  @override
  Future<void> loadInterstitial({
    required String adUnitId,
    AdRequest request = const AdRequest(),
    String? placement,
    required InterstitialAdLoadCallback adLoadCallback,
  }) {
    return RevenueCatAdMob.loadAndTrackInterstitialAd(
      adUnitId: adUnitId,
      request: request,
      placement: placement,
      adLoadCallback: adLoadCallback,
    );
  }

  @override
  void showInterstitial(InterstitialAd ad) {
    unawaited(ad.showAndTrack());
  }
}
