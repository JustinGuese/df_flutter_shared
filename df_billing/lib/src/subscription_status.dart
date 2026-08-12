import 'package:flutter/foundation.dart';

/// What the backend says about a user's entitlement.
///
/// Deliberately backend-shaped rather than Stripe-shaped: DF apps read
/// entitlement from their own API, which owns the Stripe webhook. The client
/// never talks to Stripe directly.
@immutable
class DfSubscriptionStatus {
  const DfSubscriptionStatus({
    required this.status,
    required this.isPremium,
    this.currentPeriodEnd,
    this.trialEnd,
  });

  const DfSubscriptionStatus.free() : this(status: 'free', isPremium: false);

  /// Parses the shape the DF backends return. Unknown payloads degrade to
  /// free rather than throwing — an entitlement check must never crash a
  /// screen.
  factory DfSubscriptionStatus.fromJson(Map<String, dynamic> json) {
    // Type-check rather than cast. A cast would throw on an unexpected type,
    // and an entitlement check must never be the thing that crashes a screen —
    // a malformed payload should read as "not premium", not as an exception.
    DateTime? date(String key) {
      final raw = json[key];
      return raw is String ? DateTime.tryParse(raw) : null;
    }

    final status = json['status'];
    final premium = json['is_premium'];

    return DfSubscriptionStatus(
      status: status is String ? status : 'free',
      isPremium: premium is bool ? premium : false,
      currentPeriodEnd: date('current_period_end'),
      trialEnd: date('trial_end'),
    );
  }

  /// Raw backend status, e.g. `'free'`, `'active'`, `'trialing'`, `'past_due'`.
  final String status;

  /// Whether premium content should be unlocked. Read this rather than
  /// comparing [status] strings at call sites.
  final bool isPremium;

  final DateTime? currentPeriodEnd;
  final DateTime? trialEnd;

  bool get isTrialing => status == 'trialing';

  /// Whole days left in the trial, or null when not trialing.
  ///
  /// Rounds up: with 18 hours remaining a user is still "on their last day",
  /// and `inDays` alone would say 0 while the trial is live.
  int? trialDaysRemaining({DateTime? now}) {
    final end = trialEnd;
    if (end == null) return null;
    final remaining = end.difference(now ?? DateTime.now());
    if (remaining.isNegative) return 0;
    return remaining.inHours ~/ 24 + (remaining.inHours % 24 > 0 ? 1 : 0);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'status': status,
    'is_premium': isPremium,
    if (currentPeriodEnd != null)
      'current_period_end': currentPeriodEnd!.toIso8601String(),
    if (trialEnd != null) 'trial_end': trialEnd!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is DfSubscriptionStatus &&
      other.status == status &&
      other.isPremium == isPremium &&
      other.currentPeriodEnd == currentPeriodEnd &&
      other.trialEnd == trialEnd;

  @override
  int get hashCode =>
      Object.hash(status, isPremium, currentPeriodEnd, trialEnd);

  @override
  String toString() =>
      'DfSubscriptionStatus($status, premium: $isPremium, trialEnd: $trialEnd)';
}
