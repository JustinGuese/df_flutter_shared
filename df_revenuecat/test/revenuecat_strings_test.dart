import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfRevenueCatStrings', () {
    test('default strings are in English', () {
      const strings = DfRevenueCatStrings();
      expect(strings.upgradeLabel, 'Upgrade to Pro');
      expect(strings.trialStartTemplate, 'Start {days}-day free trial');
      expect(strings.trialTryTemplate, 'Try Pro free for {days} days');
      expect(strings.webDialogTitle, 'Premium Subscription');
      expect(strings.webDialogButtonLabel, 'Got it');
    });

    test('fill replaces placeholder correctly', () {
      final res = DfRevenueCatStrings.fill('Get {days} days of {feature} now', {
        'days': 14,
        'feature': 'Pro',
      });
      expect(res, 'Get 14 days of Pro now');
    });

    test('fillTrialStart and fillTrialTry produce expected copy', () {
      const strings = DfRevenueCatStrings();
      expect(strings.fillTrialStart(7), 'Start 7-day free trial');
      expect(strings.fillTrialTry(30), 'Try Pro free for 30 days');
    });
  });
}
