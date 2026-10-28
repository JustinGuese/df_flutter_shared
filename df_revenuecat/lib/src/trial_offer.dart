import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_strings.dart';

/// The free trial duration and labels a user can start on a subscription.
@immutable
class DfTrialOffer {
  const DfTrialOffer(this.days, {this.strings = const DfRevenueCatStrings()});

  /// Duration of the trial in days.
  final int days;

  /// Localized copy source.
  final DfRevenueCatStrings strings;

  /// Formatted button label (e.g. "Start 7-day free trial").
  String get startLabel => strings.fillTrialStart(days);

  /// Formatted headline or pitch (e.g. "Try Pro free for 7 days").
  String get tryLabel => strings.fillTrialTry(days);

  /// Converts a [PeriodUnit] and [value] into day count, or null for unknown.
  static int? periodToDays(PeriodUnit unit, int value) {
    switch (unit) {
      case PeriodUnit.day:
        return value;
      case PeriodUnit.week:
        return value * 7;
      case PeriodUnit.month:
        return value * 30;
      case PeriodUnit.year:
        return value * 365;
      case PeriodUnit.unknown:
        return null;
    }
  }

  /// Extracts trial duration in days from [product], or null if none.
  static int? trialDaysForProduct(StoreProduct product) {
    final free = product.defaultOption?.freePhase?.billingPeriod;
    if (free != null) return periodToDays(free.unit, free.value);
    final intro = product.introductoryPrice;
    if (intro != null && intro.price == 0) {
      return periodToDays(
        intro.periodUnit,
        intro.periodNumberOfUnits * intro.cycles,
      );
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DfTrialOffer && other.days == days);

  @override
  int get hashCode => days.hashCode;

  @override
  String toString() => 'DfTrialOffer(days: $days)';
}
