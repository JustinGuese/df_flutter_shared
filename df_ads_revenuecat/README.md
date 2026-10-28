# df_ads_revenuecat

RevenueCat AdMob adapter for `df_ads`, bridging Google Mobile Ads and RevenueCat to report banner and interstitial ad revenue.

Used by [DataFortress.cloud](https://datafortress.cloud/) apps.

---

## Why this package exists

`purchases_flutter` adds the Play `BILLING` permission and the RevenueCat SDK; `google_mobile_ads` crashes on Android launch without an AdMob app ID in the manifest.
Separating ads and paywalls into distinct packages allows apps needing only ads or only billing to avoid unused native SDKs.
`df_ads_revenuecat` implements `DfAdFactory` from `df_ads` using `purchases_admob_flutter` for applications that use both.

---

## Installation

```yaml
dependencies:
  df_ads:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_ads
      ref: main
  df_ads_revenuecat:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_ads_revenuecat
      ref: main
```

```dart
import 'package:df_ads_revenuecat/df_ads_revenuecat.dart';
```

---

## Quick start

Plug `DfRevenueCatAdFactory` into `DfAds.configure`:

```dart
import 'package:df_ads/df_ads.dart';
import 'package:df_ads_revenuecat/df_ads_revenuecat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DfAds.configure(
    ids: const DfAdUnitIds(
      androidBanner: 'ca-app-pub-xxx/yyy',
      iosBanner: 'ca-app-pub-xxx/yyy',
      androidInterstitial: 'ca-app-pub-xxx/yyy',
      iosInterstitial: 'ca-app-pub-xxx/yyy',
    ),
    factory: const DfRevenueCatAdFactory(),
  );

  await DfAds.initialize();
  runApp(const MyApp());
}
```

Banner ads (`DfBannerAdSlot`), card ads (`DfCardAd`), and interstitials (`DfInterstitialCadence`) will automatically route through `RevenueCatAdMob`, tracking impressions, clicks, and revenue.
