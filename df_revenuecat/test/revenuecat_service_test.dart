import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

void main() {
  group('DfPaywallResult', () {
    test('isSuccess is true only for purchased and restored', () {
      expect(DfPaywallResult.purchased.isSuccess, isTrue);
      expect(DfPaywallResult.restored.isSuccess, isTrue);
      expect(DfPaywallResult.notPresented.isSuccess, isFalse);
      expect(DfPaywallResult.cancelled.isSuccess, isFalse);
      expect(DfPaywallResult.error.isSuccess, isFalse);
    });

    test('toDfPaywallResult converts from PurchasesUI PaywallResult', () {
      expect(
        PaywallResult.notPresented.toDfPaywallResult(),
        DfPaywallResult.notPresented,
      );
      expect(
        PaywallResult.cancelled.toDfPaywallResult(),
        DfPaywallResult.cancelled,
      );
      expect(PaywallResult.error.toDfPaywallResult(), DfPaywallResult.error);
      expect(
        PaywallResult.purchased.toDfPaywallResult(),
        DfPaywallResult.purchased,
      );
      expect(
        PaywallResult.restored.toDfPaywallResult(),
        DfPaywallResult.restored,
      );
    });
  });

  group('DfRevenueCat configuration', () {
    setUp(DfRevenueCat.debugReset);
    tearDown(DfRevenueCat.debugReset);

    test('isConfigured reflects state', () {
      expect(DfRevenueCat.isConfigured, isFalse);
      DfRevenueCat.configure(
        const DfRevenueCatConfig(
          iosApiKey: 'ios',
          androidApiKey: 'android',
          entitlementId: 'pro',
        ),
      );
      expect(DfRevenueCat.isConfigured, isTrue);
      expect(DfRevenueCat.config.entitlementId, 'pro');
    });
  });
}
