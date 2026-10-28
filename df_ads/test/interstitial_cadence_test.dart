import 'package:df_ads/df_ads.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAdFactory implements DfAdFactory {
  int loadCalls = 0;
  int showCalls = 0;
  String? lastPlacement;
  String? lastAdUnitId;
  InterstitialAdLoadCallback? lastCallback;

  @override
  BannerAd createBanner({
    required String adUnitId,
    required AdSize size,
    AdRequest request = const AdRequest(),
    String? placement,
    BannerAdListener? listener,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> loadInterstitial({
    required String adUnitId,
    AdRequest request = const AdRequest(),
    String? placement,
    required InterstitialAdLoadCallback adLoadCallback,
  }) async {
    loadCalls++;
    lastAdUnitId = adUnitId;
    lastPlacement = placement;
    lastCallback = adLoadCallback;
  }

  @override
  void showInterstitial(InterstitialAd ad) {
    showCalls++;
  }
}

void main() {
  late _RecordingAdFactory fakeFactory;

  setUp(() {
    fakeFactory = _RecordingAdFactory();
    DfAds.resetForTesting();
  });

  tearDown(() {
    DfAds.resetForTesting();
  });

  group('DfInterstitialCadence', () {
    test('fires at multiples only, never at 0, never when suppressed', () {
      final cadence = DfInterstitialCadence(
        every: 5,
        factory: fakeFactory,
        adUnitId: 'test-interstitial-id',
      );

      // Count 0: never fires
      cadence.maybeShow(count: 0, placement: 'swipe');
      expect(fakeFactory.loadCalls, 0);

      // Counts 1 to 4: does not fire
      for (var i = 1; i < 5; i++) {
        cadence.maybeShow(count: i, placement: 'swipe');
      }
      expect(fakeFactory.loadCalls, 0);

      // Count 5: fires
      cadence.maybeShow(count: 5, placement: 'swipe');
      expect(fakeFactory.loadCalls, 1);
      expect(fakeFactory.lastPlacement, 'swipe');
      expect(fakeFactory.lastAdUnitId, 'test-interstitial-id');

      // Count 6 to 9: does not fire
      for (var i = 6; i < 10; i++) {
        cadence.maybeShow(count: i, placement: 'swipe');
      }
      expect(fakeFactory.loadCalls, 1);

      // Count 10: fires again
      cadence.maybeShow(count: 10, placement: 'swipe_10');
      expect(fakeFactory.loadCalls, 2);
      expect(fakeFactory.lastPlacement, 'swipe_10');

      // Count 15 with suppressed: true -> must NOT fire
      cadence.maybeShow(
        count: 15,
        suppressed: true,
        placement: 'swipe_suppressed',
      );
      expect(fakeFactory.loadCalls, 2);

      // Count 15 with suppressed: false -> fires
      cadence.maybeShow(count: 15, suppressed: false, placement: 'swipe_15');
      expect(fakeFactory.loadCalls, 3);
      expect(fakeFactory.lastPlacement, 'swipe_15');
    });

    test('uses DfAds.factory and DfAds.ids when not injected', () {
      DfAds.configure(
        ids: const DfAdUnitIds(
          androidInterstitial: 'configured-id',
          isReleaseOverride: true,
        ),
        factory: fakeFactory,
      );

      const cadence = DfInterstitialCadence(every: 3);
      cadence.maybeShow(count: 3, placement: 'configured_placement');

      expect(fakeFactory.loadCalls, 1);
      expect(fakeFactory.lastPlacement, 'configured_placement');
    });

    test('does not fire on web platform', () {
      DfAds.debugIsWebOverride = true;

      final cadence = DfInterstitialCadence(every: 5, factory: fakeFactory);
      cadence.maybeShow(count: 5);

      expect(fakeFactory.loadCalls, 0);
    });

    test('ignores non-positive intervals or counts safely', () {
      final invalidCadence = DfInterstitialCadence(
        every: 0,
        factory: fakeFactory,
      );
      invalidCadence.maybeShow(count: 0);
      invalidCadence.maybeShow(count: 5);
      expect(fakeFactory.loadCalls, 0);

      final cadence = DfInterstitialCadence(every: 5, factory: fakeFactory);
      cadence.maybeShow(count: -5);
      expect(fakeFactory.loadCalls, 0);
    });

    test('static showIfDue helper works equivalently', () {
      DfInterstitialCadence.showIfDue(
        every: 4,
        count: 4,
        factory: fakeFactory,
        placement: 'static_placement',
      );

      expect(fakeFactory.loadCalls, 1);
      expect(fakeFactory.lastPlacement, 'static_placement');
    });

    test('handles failed ad load gracefully without throwing', () {
      final cadence = DfInterstitialCadence(every: 5, factory: fakeFactory);
      cadence.maybeShow(count: 5);

      expect(fakeFactory.loadCalls, 1);
      expect(fakeFactory.lastCallback, isNotNull);

      // Simulate failure callback
      expect(
        () => fakeFactory.lastCallback!.onAdFailedToLoad(
          LoadAdError(1, 'domain', 'message', null),
        ),
        returnsNormally,
      );
      expect(fakeFactory.showCalls, 0);
    });
  });
}
