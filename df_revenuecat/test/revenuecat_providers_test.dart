import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    DfRevenueCat.debugReset();
    DfRevenueCat.configure(
      const DfRevenueCatConfig(
        iosApiKey: 'ios',
        androidApiKey: 'android',
        entitlementId: 'pro',
      ),
    );
  });

  tearDown(DfRevenueCat.debugReset);

  test(
    'dfRevenueCatIsProProvider returns false when customer info is loading',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(dfRevenueCatIsProProvider), isFalse);
    },
  );
}
