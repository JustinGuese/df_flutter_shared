import 'package:df_ads/df_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('DfAdUnitIds', () {
    test('returns test ids in debug for both Android and iOS', () {
      const ids = DfAdUnitIds(
        androidBanner: 'prod-android-banner',
        iosBanner: 'prod-ios-banner',
        androidInterstitial: 'prod-android-interstitial',
        iosInterstitial: 'prod-ios-interstitial',
      );

      // Debug Android
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(ids.banner, DfAdUnitIds.testAndroidBanner);
      expect(ids.interstitial, DfAdUnitIds.testAndroidInterstitial);

      // Debug iOS
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(ids.banner, DfAdUnitIds.testIosBanner);
      expect(ids.interstitial, DfAdUnitIds.testIosInterstitial);
    });

    test('returns production ids when in release mode on Android and iOS', () {
      const ids = DfAdUnitIds(
        androidBanner: 'prod-android-banner',
        iosBanner: 'prod-ios-banner',
        androidInterstitial: 'prod-android-interstitial',
        iosInterstitial: 'prod-ios-interstitial',
        isReleaseOverride: true,
      );

      // Release Android
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(ids.banner, 'prod-android-banner');
      expect(ids.interstitial, 'prod-android-interstitial');

      // Release iOS
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(ids.banner, 'prod-ios-banner');
      expect(ids.interstitial, 'prod-ios-interstitial');
    });

    test('returns test ids on non-mobile platforms even in release mode', () {
      const ids = DfAdUnitIds(
        androidBanner: 'prod-android-banner',
        iosBanner: 'prod-ios-banner',
        androidInterstitial: 'prod-android-interstitial',
        iosInterstitial: 'prod-ios-interstitial',
        isReleaseOverride: true,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(ids.banner, DfAdUnitIds.testAndroidBanner);
      expect(ids.interstitial, DfAdUnitIds.testAndroidInterstitial);

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(ids.banner, DfAdUnitIds.testAndroidBanner);
      expect(ids.interstitial, DfAdUnitIds.testAndroidInterstitial);
    });

    test('default constructor uses Google test IDs as fallbacks', () {
      const ids = DfAdUnitIds(isReleaseOverride: true);

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(ids.banner, DfAdUnitIds.testAndroidBanner);
      expect(ids.interstitial, DfAdUnitIds.testAndroidInterstitial);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(ids.banner, DfAdUnitIds.testIosBanner);
      expect(ids.interstitial, DfAdUnitIds.testIosInterstitial);
    });
  });
}
