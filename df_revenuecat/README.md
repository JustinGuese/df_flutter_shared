# df_revenuecat

Generic RevenueCat subscription and paywall harness wrapping `purchases_flutter` and `purchases_ui_flutter` with analytics, free trials, exit offers, and paywalls. Pure billing logic and UI coordination — app-agnostic, token-driven, English-default copy.

Used by [DataFortress.cloud](https://datafortress.cloud/) apps.

---

## Installation

```yaml
dependencies:
  df_revenuecat:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_revenuecat
      ref: main
```

```dart
import 'package:df_revenuecat/df_revenuecat.dart';
```

---

## Quick start

### 1. Configuration & Initialization

```dart
await DfRevenueCat.initialize(
  config: const DfRevenueCatConfig(
    iosApiKey: 'appl_...',
    androidApiKey: 'goog_...',
    entitlementId: 'my_app_pro',
    defaultOfferingId: 'default',
    exitOfferPlacement: 'exit_offer',
    exitOfferAfter: {'onboarding', 'feed_sheet', 'app_bar_pill'},
  ),
);
```

### 2. Presenting Paywalls & Handling Analytics

```dart
final result = await DfPaywallLauncher.show(
  context,
  placement: 'onboarding',
  onPurchased: (context) async {
    // Schedule reminders, trigger account sync, etc.
  },
  onWeb: (context) async {
    // Optional custom web info dialog
  },
);
```

### 3. Riverpod State

```dart
// Check Pro status reactively
final isPro = ref.watch(dfRevenueCatIsProProvider);

// Check eligible trial length for annual plan
final trialOffer = ref.watch(dfTrialOfferProvider);
trialOffer.whenData((trial) {
  if (trial != null) {
    print('Available trial: ${trial.startLabel}'); // "Start 7-day free trial"
  }
});
```

---

## Features

- **`DfRevenueCat`**: Static wrapper for SDK initialization, authentication (`logIn`/`logOut`), status checking (`isPro`, `customerInfo`), `restore`, `activeTrialEnd()`, and paywall presentation. Web-safe.
- **`DfRevenueCatConfig`**: Configuration class with API keys, entitlement ID, default offering ID, and exit-offer placement set.
- **`DfPaywallLauncher`**: Paywall presentation orchestrator that tracks `paywall_opened` and `paywall_result` via `DfAnalyticsCore`, shows exit offers on dismiss (at most once per install), handles web fallbacks, and executes post-purchase hooks.
- **`DfPaywallResult`**: Package-own result enum (`notPresented`, `cancelled`, `error`, `purchased`, `restored`) decoupling consuming apps from `purchases_ui_flutter`.
- **`DfTrialOffer`**: Calculates trial durations from `StoreProduct` introductory / free phase data and provides formatted labels.
- **`dfRevenueCatCustomerInfoProvider` & `dfRevenueCatIsProProvider`**: Riverpod providers for real-time subscription status.
- **`dfTrialOfferProvider`**: Riverpod provider checking trial eligibility and offerings.
- **`DfRevenueCatStrings`**: English default strings for copy and buttons with `{placeholder}` interpolation.
