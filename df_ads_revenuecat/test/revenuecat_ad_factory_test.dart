import 'package:df_ads/df_ads.dart';
import 'package:df_ads_revenuecat/df_ads_revenuecat.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInterstitialAd extends Fake implements InterstitialAd {
  bool showCalled = false;

  @override
  Future<void> show() async {
    showCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const gmaChannelName = 'plugins.flutter.io/google_mobile_ads';
  const purchasesChannel = MethodChannel('purchases_flutter');
  final rawGmaMessages = <ByteData>[];

  setUp(() {
    rawGmaMessages.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(gmaChannelName, (ByteData? message) async {
          if (message != null) {
            rawGmaMessages.add(message);
          }
          return const StandardMethodCodec().encodeSuccessEnvelope(null);
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(purchasesChannel, (call) async {
          if (call.method == 'isConfigured') {
            return false;
          }
          return null;
        });

    DfAds.resetForTesting();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(gmaChannelName, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(purchasesChannel, null);
    DfAds.resetForTesting();
  });

  group('DfRevenueCatAdFactory', () {
    test('implements DfAdFactory and supports const instantiation', () {
      const factory = DfRevenueCatAdFactory();
      expect(factory, isA<DfAdFactory>());
    });

    test('can be plugged into DfAds.configure', () {
      const factory = DfRevenueCatAdFactory();
      DfAds.configure(factory: factory);
      expect(DfAds.factory, same(factory));
    });

    test('createBanner creates a BannerAd with tracking listener', () {
      const factory = DfRevenueCatAdFactory();
      var userLoaded = false;
      var userFailed = false;

      final banner = factory.createBanner(
        adUnitId: 'test-banner-unit-id',
        size: AdSize.banner,
        placement: 'home_banner',
        listener: BannerAdListener(
          onAdLoaded: (_) => userLoaded = true,
          onAdFailedToLoad: (ad, error) => userFailed = true,
        ),
      );

      expect(banner.adUnitId, 'test-banner-unit-id');
      expect(banner.size, AdSize.banner);
      expect(banner.listener, isNotNull);

      // Verify wrapped listener forwards callbacks to the user listener
      banner.listener.onAdLoaded?.call(banner);
      expect(userLoaded, isTrue);

      banner.listener.onAdFailedToLoad?.call(
        banner,
        LoadAdError(1, 'domain', 'msg', null),
      );
      expect(userFailed, isTrue);
    });

    test(
      'loadInterstitial dispatches load request to platform channel',
      () async {
        const factory = DfRevenueCatAdFactory();
        var failed = false;

        await factory.loadInterstitial(
          adUnitId: 'test-interstitial-unit-id',
          placement: 'swipe_interstitial',
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (_) {},
            onAdFailedToLoad: (_) => failed = true,
          ),
        );

        expect(rawGmaMessages, isNotEmpty);
        expect(failed, isFalse);
      },
    );

    test('showInterstitial delegates to showAndTrack on InterstitialAd', () {
      const factory = DfRevenueCatAdFactory();
      final fakeAd = _FakeInterstitialAd();

      factory.showInterstitial(fakeAd);

      expect(fakeAd.showCalled, isTrue);
    });

    test('works with DfInterstitialCadence to evaluate and trigger loads', () {
      const factory = DfRevenueCatAdFactory();
      const cadence = DfInterstitialCadence(
        every: 3,
        factory: factory,
        adUnitId: 'cadence-unit-id',
      );

      // Count 1: does not trigger load
      cadence.maybeShow(count: 1);
      expect(rawGmaMessages, isEmpty);

      // Count 3: multiple of 3, triggers interstitial load
      cadence.maybeShow(count: 3, placement: 'cadence_placement');
      expect(rawGmaMessages, hasLength(1));
    });
  });
}
