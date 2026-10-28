import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  group('DfTrialOffer periodToDays', () {
    test('converts PeriodUnit.day correctly', () {
      expect(DfTrialOffer.periodToDays(PeriodUnit.day, 1), 1);
      expect(DfTrialOffer.periodToDays(PeriodUnit.day, 3), 3);
      expect(DfTrialOffer.periodToDays(PeriodUnit.day, 14), 14);
    });

    test('converts PeriodUnit.week correctly', () {
      expect(DfTrialOffer.periodToDays(PeriodUnit.week, 1), 7);
      expect(DfTrialOffer.periodToDays(PeriodUnit.week, 2), 14);
      expect(DfTrialOffer.periodToDays(PeriodUnit.week, 4), 28);
    });

    test('converts PeriodUnit.month correctly', () {
      expect(DfTrialOffer.periodToDays(PeriodUnit.month, 1), 30);
      expect(DfTrialOffer.periodToDays(PeriodUnit.month, 3), 90);
    });

    test('converts PeriodUnit.year correctly', () {
      expect(DfTrialOffer.periodToDays(PeriodUnit.year, 1), 365);
      expect(DfTrialOffer.periodToDays(PeriodUnit.year, 2), 730);
    });

    test('converts PeriodUnit.unknown to null', () {
      expect(DfTrialOffer.periodToDays(PeriodUnit.unknown, 1), isNull);
      expect(DfTrialOffer.periodToDays(PeriodUnit.unknown, 5), isNull);
    });
  });

  group('DfTrialOffer labels', () {
    test('formats startLabel and tryLabel with English defaults', () {
      const offer = DfTrialOffer(7);
      expect(offer.days, 7);
      expect(offer.startLabel, 'Start 7-day free trial');
      expect(offer.tryLabel, 'Try Pro free for 7 days');
    });

    test('formats labels with custom strings', () {
      const customStrings = DfRevenueCatStrings(
        trialStartTemplate: 'Begin your {days} days trial',
        trialTryTemplate: '{days} days on us',
      );
      const offer = DfTrialOffer(14, strings: customStrings);
      expect(offer.startLabel, 'Begin your 14 days trial');
      expect(offer.tryLabel, '14 days on us');
    });

    test('implements value equality and hashCode', () {
      const a = DfTrialOffer(7);
      const b = DfTrialOffer(7);
      const c = DfTrialOffer(14);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
