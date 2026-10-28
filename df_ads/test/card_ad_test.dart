import 'package:df_ads/df_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestBannerAd extends BannerAd {
  _TestBannerAd({
    required super.size,
    required super.adUnitId,
    required super.listener,
    required super.request,
    this.shouldFail = false,
    this.autoComplete = false,
  });

  final bool shouldFail;
  final bool autoComplete;

  @override
  Future<void> load() async {
    if (shouldFail) {
      listener.onAdFailedToLoad?.call(
        this,
        LoadAdError(1, 'test', 'Test load failure', null),
      );
    } else if (autoComplete) {
      listener.onAdLoaded?.call(this);
    }
  }

  @override
  Future<void> dispose() async {}
}

class _CardTestAdFactory implements DfAdFactory {
  _CardTestAdFactory({this.shouldFail = false, this.autoComplete = false});

  final bool shouldFail;
  final bool autoComplete;
  int createCalls = 0;
  String? lastPlacement;

  @override
  BannerAd createBanner({
    required String adUnitId,
    required AdSize size,
    AdRequest request = const AdRequest(),
    String? placement,
    BannerAdListener? listener,
  }) {
    createCalls++;
    lastPlacement = placement;
    return _TestBannerAd(
      size: size,
      adUnitId: adUnitId,
      listener: listener ?? const BannerAdListener(),
      request: request,
      shouldFail: shouldFail,
      autoComplete: autoComplete,
    );
  }

  @override
  Future<void> loadInterstitial({
    required String adUnitId,
    AdRequest request = const AdRequest(),
    String? placement,
    required InterstitialAdLoadCallback adLoadCallback,
  }) async {}

  @override
  void showInterstitial(InterstitialAd ad) {}
}

void main() {
  setUp(() {
    DfAds.resetForTesting();
  });

  tearDown(() {
    DfAds.resetForTesting();
  });

  group('DfCardAd', () {
    testWidgets('renders fallback on web without calling factory', (
      tester,
    ) async {
      DfAds.debugIsWebOverride = true;
      final factory = _CardTestAdFactory();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfCardAd(
              placement: 'swipe_ad_card',
              isFront: true,
              adFactory: factory,
              fallback: (context) => const Text('FALLBACK_HOUSE_CARD'),
            ),
          ),
        ),
      );

      expect(find.text('FALLBACK_HOUSE_CARD'), findsOneWidget);
      expect(factory.createCalls, 0);
    });

    testWidgets('renders fallback on ad load failure', (tester) async {
      final factory = _CardTestAdFactory(shouldFail: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfCardAd(
              placement: 'swipe_ad_card',
              isFront: true,
              adFactory: factory,
              fallback: (context) => const Text('FALLBACK_ON_ERROR'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('FALLBACK_ON_ERROR'), findsOneWidget);
      expect(factory.createCalls, 1);
    });

    testWidgets('loads only when isFront is true', (tester) async {
      final factory = _CardTestAdFactory();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfCardAd(
              placement: 'swipe_ad_card',
              isFront: false,
              adFactory: factory,
              fallback: (context) => const Text('FALLBACK'),
            ),
          ),
        ),
      );

      // Not front -> factory not called
      expect(factory.createCalls, 0);

      // Transition to front
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfCardAd(
              placement: 'swipe_ad_card',
              isFront: true,
              adFactory: factory,
              fallback: (context) => const Text('FALLBACK'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(factory.createCalls, 1);
      expect(factory.lastPlacement, 'swipe_ad_card');
    });

    testWidgets('renders eyebrow from strings and action widget', (
      tester,
    ) async {
      final factory = _CardTestAdFactory();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfCardAd(
              placement: 'swipe_ad_card',
              isFront: true,
              adFactory: factory,
              strings: const DfAdsStrings(
                advertisementEyebrow: 'CUSTOM_EYEBROW',
              ),
              action: const Text('CUSTOM_ACTION_BUTTON'),
              fallback: (context) => const Text('FALLBACK'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('CUSTOM_EYEBROW'), findsOneWidget);
      expect(find.text('CUSTOM_ACTION_BUTTON'), findsOneWidget);
    });

    testWidgets('renders custom adBuilder when loaded successfully', (
      tester,
    ) async {
      final factory = _CardTestAdFactory(autoComplete: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfCardAd(
              placement: 'swipe_ad_card',
              isFront: true,
              adFactory: factory,
              adBuilder: (context, ad) => const Text('RENDERED_AD_CONTENT'),
              fallback: (context) => const Text('FALLBACK'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('RENDERED_AD_CONTENT'), findsOneWidget);
      expect(find.text('ADVERTISEMENT'), findsOneWidget);
    });
  });
}
