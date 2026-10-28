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
  });

  final bool shouldFail;

  @override
  Future<void> load() async {
    if (shouldFail) {
      listener.onAdFailedToLoad?.call(
        this,
        LoadAdError(1, 'test', 'Test banner load failure', null),
      );
    } else {
      listener.onAdLoaded?.call(this);
    }
  }

  @override
  Future<void> dispose() async {}
}

class _BannerTestAdFactory implements DfAdFactory {
  _BannerTestAdFactory({this.shouldFail = false});

  final bool shouldFail;
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

  group('DfBannerAdSlot', () {
    testWidgets('renders below alone on web without requesting ad', (
      tester,
    ) async {
      DfAds.debugIsWebOverride = true;
      final factory = _BannerTestAdFactory();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfBannerAdSlot(
              placement: 'home_banner',
              adFactory: factory,
              below: const Text('UPGRADE_STRIP'),
            ),
          ),
        ),
      );

      expect(find.text('UPGRADE_STRIP'), findsOneWidget);
      expect(factory.createCalls, 0);
    });

    testWidgets('renders below alone on ad failure', (tester) async {
      final factory = _BannerTestAdFactory(shouldFail: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfBannerAdSlot(
              placement: 'home_banner',
              adFactory: factory,
              below: const Text('UPGRADE_STRIP'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('UPGRADE_STRIP'), findsOneWidget);
      expect(factory.createCalls, 1);
    });

    testWidgets('renders ad + below when ad loads successfully', (
      tester,
    ) async {
      final factory = _BannerTestAdFactory();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfBannerAdSlot(
              placement: 'home_banner',
              adFactory: factory,
              adBuilder: (context, ad) => const Text('RENDERED_BANNER'),
              below: const Text('UPGRADE_STRIP'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('RENDERED_BANNER'), findsOneWidget);
      expect(find.text('UPGRADE_STRIP'), findsOneWidget);
      expect(factory.createCalls, 1);
    });

    testWidgets('returns SizedBox.shrink when below is null and no ad loaded', (
      tester,
    ) async {
      DfAds.debugIsWebOverride = true;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DfBannerAdSlot(placement: 'home_banner')),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('UPGRADE_STRIP'), findsNothing);
    });
  });
}
