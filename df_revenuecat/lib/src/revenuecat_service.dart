import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'paywall_presenter.dart';
import 'revenuecat_config.dart';

export 'paywall_presenter.dart' show DfPaywallPresenter, DfPaywallResult;

/// Converts a RevenueCat UI [PaywallResult] to package-own [DfPaywallResult].
extension DfPaywallResultFromRevenueCat on PaywallResult {
  DfPaywallResult toDfPaywallResult() => switch (this) {
    PaywallResult.notPresented => DfPaywallResult.notPresented,
    PaywallResult.cancelled => DfPaywallResult.cancelled,
    PaywallResult.error => DfPaywallResult.error,
    PaywallResult.purchased => DfPaywallResult.purchased,
    PaywallResult.restored => DfPaywallResult.restored,
  };
}

/// Static service wrapping RevenueCat SDK operations.
abstract final class DfRevenueCat {
  static DfRevenueCatConfig? _config;
  static DfPaywallPresenter? _presenter;

  /// Active configuration. Must be initialized via [initialize] or [configure].
  static DfRevenueCatConfig get config {
    final cfg = _config;
    assert(cfg != null, 'DfRevenueCat must be configured before use');
    return cfg ??
        const DfRevenueCatConfig(
          iosApiKey: '',
          androidApiKey: '',
          entitlementId: '',
        );
  }

  /// Whether [DfRevenueCat] has been configured.
  static bool get isConfigured => _config != null;

  /// Sets the active [DfRevenueCatConfig] without configuring the SDK.
  static void configure(DfRevenueCatConfig config) => _config = config;

  /// Injectable presenter for paywall operations, replaced in tests.
  static DfPaywallPresenter get presenter =>
      _presenter ?? const DefaultPaywallPresenter();

  @visibleForTesting
  static set presenter(DfPaywallPresenter? value) => _presenter = value;

  /// Resets test overrides and configuration.
  @visibleForTesting
  static void debugReset() {
    _config = null;
    _presenter = null;
  }

  /// Initializes RevenueCat with [config] and optional [appUserId]. Web-safe.
  static Future<void> initialize({
    DfRevenueCatConfig? config,
    String? appUserId,
  }) async {
    if (config != null) _config = config;
    if (kIsWeb) return;
    final active = _config;
    if (active == null) {
      assert(false, 'DfRevenueCat.initialize called without configuration');
      return;
    }
    await Purchases.setLogLevel(kReleaseMode ? LogLevel.warn : LogLevel.debug);
    final configuration = PurchasesConfiguration(active.apiKey);
    if (appUserId != null && appUserId.isNotEmpty) {
      configuration.appUserID = appUserId;
    }
    await Purchases.configure(configuration);
  }

  /// Identifies the user in RevenueCat. Web-safe.
  static Future<CustomerInfo?> logIn(String appUserId) async {
    if (kIsWeb) return null;
    try {
      final result = await Purchases.logIn(appUserId);
      return result.customerInfo;
    } catch (e) {
      debugPrint('DfRevenueCat logIn error: $e');
      return null;
    }
  }

  /// Logs out of RevenueCat. Web-safe.
  static Future<CustomerInfo?> logOut() async {
    if (kIsWeb) return null;
    try {
      return await Purchases.logOut();
    } catch (e) {
      debugPrint('DfRevenueCat logOut error: $e');
      return null;
    }
  }

  /// Fetches current [CustomerInfo]. Web-safe.
  static Future<CustomerInfo?> customerInfo() async {
    if (kIsWeb) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('DfRevenueCat customerInfo error: $e');
      return null;
    }
  }

  /// Checks whether the user has the configured entitlement active. Web-safe.
  static Future<bool> isPro() async {
    if (kIsWeb) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active[config.entitlementId] != null;
    } catch (e) {
      debugPrint('DfRevenueCat isPro error: $e');
      return false;
    }
  }

  /// Restores previous purchases. Web-safe.
  static Future<bool> restore() async {
    if (kIsWeb) return false;
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active[config.entitlementId] != null;
    } catch (e) {
      debugPrint('DfRevenueCat restore error: $e');
      return false;
    }
  }

  /// Looks up targeted offering for [placement], falling back to [defaultOfferingId].
  static Future<Offering?> offeringFor(String? placement) async {
    if (kIsWeb) return null;
    try {
      if (placement != null && placement.isNotEmpty) {
        final targeted = await Purchases.getCurrentOfferingForPlacement(
          placement,
        );
        if (targeted != null) return targeted;
      }
      final offerings = await Purchases.getOfferings();
      return offerings.getOffering(config.defaultOfferingId) ??
          offerings.current;
    } catch (e) {
      debugPrint('DfRevenueCat offering lookup error: $e');
      return null;
    }
  }

  /// Returns expiry DateTime if entitlement has active trial period, else null.
  static Future<DateTime?> activeTrialEnd() async {
    if (kIsWeb) return null;
    try {
      final info = await customerInfo();
      final entitlement = info?.entitlements.active[config.entitlementId];
      if (entitlement == null || entitlement.periodType != PeriodType.trial) {
        return null;
      }
      final exp = entitlement.expirationDate;
      if (exp == null || exp.isEmpty) return null;
      return DateTime.tryParse(exp);
    } catch (e) {
      debugPrint('DfRevenueCat activeTrialEnd error: $e');
      return null;
    }
  }

  /// Presents paywall for [placement]. If [force] is true, always shows paywall.
  static Future<DfPaywallResult> presentPaywall({
    String? placement,
    bool force = false,
  }) async {
    if (kIsWeb) return DfPaywallResult.notPresented;
    return presenter.presentPaywall(placement: placement, force: force);
  }

  /// Presents the exit offer paywall at most once per install.
  static Future<DfPaywallResult> presentExitOffer({
    SharedPreferences? prefs,
  }) async {
    if (kIsWeb) return DfPaywallResult.notPresented;
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      if (p.getBool(config.exitOfferShownKey) ?? false) {
        return DfPaywallResult.notPresented;
      }
      final result = await presenter.presentExitOffer();
      if (result != DfPaywallResult.notPresented) {
        await p.setBool(config.exitOfferShownKey, true);
      }
      return result;
    } catch (e) {
      debugPrint('DfRevenueCat presentExitOffer error: $e');
      return DfPaywallResult.notPresented;
    }
  }

  /// Presents the RevenueCat Customer Center. Web-safe.
  static Future<void> presentCustomerCenter() async {
    if (kIsWeb) return;
    await presenter.presentCustomerCenter();
  }
}
