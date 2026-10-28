import 'package:df_ads/df_ads.dart';
import 'package:flutter_test/flutter_test.dart';

class _CustomFactory extends DfPlainAdFactory {
  const _CustomFactory();
}

void main() {
  setUp(() {
    DfAds.resetForTesting();
  });

  tearDown(() {
    DfAds.resetForTesting();
  });

  group('DfAds', () {
    test('default configuration provides fallback values', () {
      expect(DfAds.ids, isA<DfAdUnitIds>());
      expect(DfAds.factory, isA<DfPlainAdFactory>());
      expect(DfAds.strings, isA<DfAdsStrings>());
      expect(DfAds.isInitialized, isFalse);
    });

    test('configure updates ids, factory, and strings', () {
      const customIds = DfAdUnitIds(androidBanner: 'custom-banner');
      const customFactory = _CustomFactory();
      const customStrings = DfAdsStrings(advertisementEyebrow: 'PROMO');

      DfAds.configure(
        ids: customIds,
        factory: customFactory,
        strings: customStrings,
      );

      expect(DfAds.ids, same(customIds));
      expect(DfAds.factory, same(customFactory));
      expect(DfAds.strings, same(customStrings));
    });

    test('initialize is a no-op on web', () async {
      DfAds.debugIsWebOverride = true;

      final result = await DfAds.initialize();
      expect(result, isNull);
      expect(DfAds.isInitialized, isFalse);
    });

    test('resetForTesting restores initial state', () {
      DfAds.configure(
        ids: const DfAdUnitIds(androidBanner: 'custom'),
        strings: const DfAdsStrings(advertisementEyebrow: 'CUSTOM'),
      );
      DfAds.debugIsWebOverride = true;

      DfAds.resetForTesting();

      expect(DfAds.ids.androidBanner, DfAdUnitIds.testAndroidBanner);
      expect(DfAds.strings.advertisementEyebrow, 'ADVERTISEMENT');
      expect(DfAds.debugIsWebOverride, isNull);
      expect(DfAds.isInitialized, isFalse);
    });
  });
}
