import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfRevenueCatConfig', () {
    test('defaults are populated as expected', () {
      const config = DfRevenueCatConfig(
        iosApiKey: 'appl_123',
        androidApiKey: 'goog_456',
        entitlementId: 'pro',
      );

      expect(config.iosApiKey, 'appl_123');
      expect(config.androidApiKey, 'goog_456');
      expect(config.entitlementId, 'pro');
      expect(config.defaultOfferingId, 'default');
      expect(config.exitOfferPlacement, 'exit_offer');
      expect(config.exitOfferAfter, isEmpty);
      expect(config.exitOfferShownKey, 'exit_offer_shown');
    });

    test('apiKey selects correct platform key', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const config = DfRevenueCatConfig(
        iosApiKey: 'appl_ios',
        androidApiKey: 'goog_android',
        entitlementId: 'pro',
      );
      expect(config.apiKey, 'appl_ios');

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(config.apiKey, 'goog_android');

      debugDefaultTargetPlatformOverride = null;
    });

    test('equality and hashCode work with sets', () {
      const a = DfRevenueCatConfig(
        iosApiKey: 'a',
        androidApiKey: 'b',
        entitlementId: 'c',
        exitOfferAfter: {'x', 'y'},
      );
      const b = DfRevenueCatConfig(
        iosApiKey: 'a',
        androidApiKey: 'b',
        entitlementId: 'c',
        exitOfferAfter: {'y', 'x'},
      );
      const c = DfRevenueCatConfig(
        iosApiKey: 'a',
        androidApiKey: 'b',
        entitlementId: 'c',
        exitOfferAfter: {'x'},
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
