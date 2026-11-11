import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'premium_providers.dart';

/// Whether a paywall [DfPaywallResult] means the user may already be entitled.
///
/// Besides `purchased`/`restored`, RevenueCat returns `notPresented` when it
/// skips the paywall because the user already has the entitlement. Treating
/// that as "nothing happened" leaves the user stuck on a paywall that never
/// opens. Always confirm with [dfRefreshAndCheckEntitlement] before unlocking.
extension DfPaywallResultEntitlement on DfPaywallResult {
  bool get mayBeEntitled => isSuccess || this == DfPaywallResult.notPresented;
}

/// Authoritative entitlement check that also repairs stale cached state.
///
/// The cached providers lag a purchase or restore. This returns true straight
/// away if they already say premium; otherwise asks RevenueCat directly
/// ([check] defaults to [DfRevenueCat.isPro]) and, when entitled, refreshes the
/// customer-info cache so live guards watching [dfEffectivePremiumProvider]
/// see it.
Future<bool> dfRefreshAndCheckEntitlement(
  WidgetRef ref, {
  Future<bool> Function()? check,
  bool Function()? isMounted,
}) async {
  bool cached() =>
      ref.read(dfEffectivePremiumProvider) ||
      ref.read(dfRevenueCatIsProProvider);
  if (cached()) return true;
  final isPro = await (check ?? DfRevenueCat.isPro)();
  if (isPro && (isMounted?.call() ?? true)) {
    ref.invalidate(dfRevenueCatCustomerInfoProvider);
  }
  return isPro || cached();
}
