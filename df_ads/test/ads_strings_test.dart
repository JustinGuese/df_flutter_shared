import 'package:df_ads/df_ads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfAdsStrings', () {
    test('default strings match English specification', () {
      const strings = DfAdsStrings();
      expect(strings.advertisementEyebrow, 'ADVERTISEMENT');
      expect(strings.sponsoredLabel, 'Sponsored');
      expect(strings.removeAds, 'Remove ads');
    });

    test('supports custom overrides in constructor', () {
      const strings = DfAdsStrings(
        advertisementEyebrow: 'WERBUNG',
        sponsoredLabel: 'Gesponsert',
        removeAds: 'Werbung entfernen',
      );
      expect(strings.advertisementEyebrow, 'WERBUNG');
      expect(strings.sponsoredLabel, 'Gesponsert');
      expect(strings.removeAds, 'Werbung entfernen');
    });

    test('fill replaces placeholder tokens correctly', () {
      expect(
        DfAdsStrings.fill('Ad #{number} of {total}', {'number': 1, 'total': 3}),
        'Ad #1 of 3',
      );
      expect(
        DfAdsStrings.fill('No placeholders', {'unused': 'val'}),
        'No placeholders',
      );
    });
  });
}
