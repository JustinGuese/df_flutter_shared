/// Generic subscription state passed to paywall widgets.
/// The app is responsible for populating this from its own backend/SDK.
class PaywallSubscriptionInfo {
  /// Raw status string (e.g. "free", "trialing", "active", "canceled").
  final String status;

  /// Whether the user currently has access to premium features.
  final bool isPremium;

  /// When the current billing period ends (null if free/unknown).
  final DateTime? currentPeriodEnd;

  /// When the trial ends (null if not trialing).
  final DateTime? trialEnd;

  const PaywallSubscriptionInfo({
    required this.status,
    required this.isPremium,
    this.currentPeriodEnd,
    this.trialEnd,
  });

  const PaywallSubscriptionInfo.free()
      : status = 'free',
        isPremium = false,
        currentPeriodEnd = null,
        trialEnd = null;

  bool get isTrialing => status == 'trialing';

  /// Days remaining in the trial, clamped to [0, ∞). Null if not trialing.
  int? get trialDaysRemaining {
    if (trialEnd == null) return null;
    return trialEnd!.difference(DateTime.now()).inDays.clamp(0, 999);
  }
}
