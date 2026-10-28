import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_factory.dart';
import 'df_ads.dart';

/// Full-screen ad cadence manager.
///
/// Displays an interstitial ad every [every] events (e.g. card swipes),
/// unless ads are [suppressed] (e.g. for premium users) or running on web.
class DfInterstitialCadence {
  const DfInterstitialCadence({
    required this.every,
    this.factory,
    this.adUnitId,
  });

  /// The cadence interval. Ads fire when [count] is a positive multiple of this.
  final int every;

  /// Custom ad factory. If null, [DfAds.factory] is used.
  final DfAdFactory? factory;

  /// Custom ad unit id. If null, [DfAds.ids.interstitial] is used.
  final String? adUnitId;

  /// Evaluates whether an interstitial ad should be shown and loads/shows it.
  ///
  /// Does nothing if:
  /// - Running on web
  /// - [suppressed] is true
  /// - [count] is 0 or not a positive multiple of [every]
  /// - [every] is <= 0
  ///
  /// If the ad fails to load, nothing is shown and no error is thrown.
  void maybeShow({
    required int count,
    bool suppressed = false,
    String? placement,
    AdRequest request = const AdRequest(),
  }) {
    if (DfAds.isPlatformWeb) return;
    if (suppressed) return;
    if (every <= 0 || count <= 0 || count % every != 0) return;

    final adFactory = factory ?? DfAds.factory;
    final unitId = adUnitId ?? DfAds.ids.interstitial;

    adFactory.loadInterstitial(
      adUnitId: unitId,
      request: request,
      placement: placement,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
          );
          adFactory.showInterstitial(ad);
        },
        onAdFailedToLoad: (_) {
          // Failed load shows nothing.
        },
      ),
    );
  }

  /// Convenience static helper to evaluate and display an ad without
  /// keeping an instance around.
  static void showIfDue({
    required int every,
    required int count,
    bool suppressed = false,
    String? placement,
    DfAdFactory? factory,
    String? adUnitId,
    AdRequest request = const AdRequest(),
  }) {
    DfInterstitialCadence(
      every: every,
      factory: factory,
      adUnitId: adUnitId,
    ).maybeShow(
      count: count,
      suppressed: suppressed,
      placement: placement,
      request: request,
    );
  }
}
