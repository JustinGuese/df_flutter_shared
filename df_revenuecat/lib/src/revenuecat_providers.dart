import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_service.dart';
import 'trial_offer.dart';

/// Stream provider for RevenueCat [CustomerInfo] updates.
///
/// Dispose-safe: registers cleanup before the first await so rapid disposal
/// does not leak listeners. Web-safe.
final dfRevenueCatCustomerInfoProvider = StreamProvider<CustomerInfo>((
  ref,
) async* {
  if (kIsWeb) return;
  final controller = StreamController<CustomerInfo>();

  void listener(CustomerInfo info) {
    if (!controller.isClosed) controller.add(info);
  }

  // Register cleanup before the first await: the provider may be disposed
  // while getCustomerInfo is still in flight.
  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  });

  try {
    final info = await Purchases.getCustomerInfo();
    if (!controller.isClosed) controller.add(info);
  } catch (_) {}

  if (!controller.isClosed) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  yield* controller.stream;
});

/// Provider indicating whether the configured entitlement is active.
final dfRevenueCatIsProProvider = Provider<bool>((ref) {
  final customerInfoAsync = ref.watch(dfRevenueCatCustomerInfoProvider);
  return customerInfoAsync.maybeWhen(
    data: (info) =>
        info.entitlements.active[DfRevenueCat.config.entitlementId] != null,
    orElse: () => false,
  );
});

/// Provider yielding the user's available [DfTrialOffer], or null if ineligible,
/// already subscribed, or on error.
final dfTrialOfferProvider = FutureProvider<DfTrialOffer?>((ref) async {
  if (kIsWeb) return null;
  try {
    final info = await ref.watch(dfRevenueCatCustomerInfoProvider.future);
    if (info.entitlements.all[DfRevenueCat.config.entitlementId] != null) {
      return null;
    }
    final offerings = await Purchases.getOfferings();
    final offering =
        offerings.getOffering(DfRevenueCat.config.defaultOfferingId) ??
        offerings.current;
    final product = offering?.annual?.storeProduct;
    if (product == null) return null;
    final days = DfTrialOffer.trialDaysForProduct(product);
    if (days == null) return null;
    final eligibility =
        await Purchases.checkTrialOrIntroductoryPriceEligibility([
          product.identifier,
        ]);
    if (eligibility[product.identifier]?.status ==
        IntroEligibilityStatus.introEligibilityStatusIneligible) {
      return null;
    }
    return DfTrialOffer(days);
  } catch (e) {
    debugPrint('dfTrialOfferProvider error: $e');
    return null;
  }
});
