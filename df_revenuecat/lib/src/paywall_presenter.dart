import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'revenuecat_service.dart'
    show DfRevenueCat, DfPaywallResultFromRevenueCat;

/// Possible outcomes when presenting a paywall.
enum DfPaywallResult {
  /// Paywall was not presented (e.g. on web, or entitlement already held).
  notPresented,

  /// User dismissed the paywall without purchasing or restoring.
  cancelled,

  /// An error occurred while presenting or processing payment.
  error,

  /// User successfully purchased an entitlement.
  purchased,

  /// User successfully restored an existing purchase.
  restored;

  /// Whether the outcome is successful ([purchased] or [restored]).
  bool get isSuccess =>
      this == DfPaywallResult.purchased || this == DfPaywallResult.restored;
}

/// Seam for paywall presentations, replaced with a test double in tests.
abstract interface class DfPaywallPresenter {
  Future<DfPaywallResult> presentPaywall({
    String? placement,
    bool force = false,
  });
  Future<DfPaywallResult> presentExitOffer();
  Future<void> presentCustomerCenter();
}

class DefaultPaywallPresenter implements DfPaywallPresenter {
  const DefaultPaywallPresenter();

  @override
  Future<DfPaywallResult> presentPaywall({
    String? placement,
    bool force = false,
  }) async {
    if (kIsWeb) return DfPaywallResult.notPresented;
    try {
      final offering = await DfRevenueCat.offeringFor(placement);
      final res = force
          ? await RevenueCatUI.presentPaywall(offering: offering)
          : await RevenueCatUI.presentPaywallIfNeeded(
              DfRevenueCat.config.entitlementId,
              offering: offering,
            );
      return res.toDfPaywallResult();
    } catch (e) {
      debugPrint('DfRevenueCat presentPaywall error: $e');
      return DfPaywallResult.error;
    }
  }

  @override
  Future<DfPaywallResult> presentExitOffer() async {
    if (kIsWeb) return DfPaywallResult.notPresented;
    try {
      final offering = await Purchases.getCurrentOfferingForPlacement(
        DfRevenueCat.config.exitOfferPlacement,
      );
      if (offering == null) return DfPaywallResult.notPresented;
      final res = await RevenueCatUI.presentPaywall(offering: offering);
      return res.toDfPaywallResult();
    } catch (e) {
      debugPrint('DfRevenueCat presentExitOffer error: $e');
      return DfPaywallResult.notPresented;
    }
  }

  @override
  Future<void> presentCustomerCenter() async {
    if (kIsWeb) return;
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('RevenueCat presentCustomerCenter error: $e');
    }
  }
}
