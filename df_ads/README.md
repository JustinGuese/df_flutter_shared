# df_ads

Generic Google Mobile Ads (AdMob) harness with token-styled card ads, banner slots, and cadence management.

Used by [DataFortress.cloud](https://datafortress.cloud/) apps.

---

## Installation

```yaml
dependencies:
  df_ads:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_ads
      ref: main
```

```dart
import 'package:df_ads/df_ads.dart';
```

---

## Quick start

```dart
// 1. Configure and initialize at app launch (e.g. in main.dart)
DfAds.configure(
  ids: const DfAdUnitIds(
    androidBanner: 'ca-app-pub-xxx/yyy',
    iosBanner: 'ca-app-pub-xxx/yyy',
    androidInterstitial: 'ca-app-pub-xxx/yyy',
    iosInterstitial: 'ca-app-pub-xxx/yyy',
  ),
);
await DfAds.initialize();

// 2. Interstitial cadence (e.g. every 5 swipes)
final cadence = DfInterstitialCadence(every: 5);
cadence.maybeShow(
  count: swipeCount,
  suppressed: isProUser,
  placement: 'swipe_interstitial',
);

// 3. Banner slot (with upgrade CTA below or standalone when no ad)
DfBannerAdSlot(
  placement: 'home_banner',
  below: TextButton(
    onPressed: openPaywall,
    child: const Text('Remove ads · Try Pro free'),
  ),
);

// 4. Swipeable card ad (loads only when on top, fallbacks on error/web)
DfCardAd(
  placement: 'swipe_ad_card',
  isFront: isTopCard,
  fallback: (context) => HouseSponsorCard(),
  action: TextButton.icon(
    onPressed: openPaywall,
    icon: const Icon(Icons.block_rounded, size: 16),
    label: const Text('Remove ads — try Pro free'),
  ),
);
```

---

## Components

- **`DfAdUnitIds`**: AdMob ad unit ID container with Google's public test IDs built in; `.banner` and `.interstitial` return test IDs in debug mode and real IDs in release mode on Android/iOS.
- **`DfAdFactory`**: Pluggable interface for banner and interstitial creation (default `DfPlainAdFactory`, or `DfRevenueCatAdFactory` from `df_ads_revenuecat`).
- **`DfAds`**: Static configurator and SDK initializer (`DfAds.configure`, `DfAds.initialize`).
- **`DfInterstitialCadence`**: Fires full-screen interstitial ads at multiples of N events, never on 0, and never when suppressed.
- **`DfBannerAdSlot`**: Banner ad slot that gracefully displays a fallback widget (e.g. upgrade strip) when no ad is loaded, or banner + widget when loaded.
- **`DfCardAd`**: Medium-rectangle card styled with DF tokens. Only loads once the card reaches the front of the stack, and falls back to a custom builder on web or failure.
- **`DfAdsStrings`**: Localizable copy for ad card headers and placeholders with English defaults and `{placeholder}` support.
