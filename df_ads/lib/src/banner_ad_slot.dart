import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_factory.dart';
import 'df_ads.dart';

/// Banner ad slot.
///
/// When an ad is loaded, renders the banner ad with [below] widget beneath it
/// (if provided).
/// When no ad is loaded (or on web, or on load failure), renders [below] alone.
class DfBannerAdSlot extends StatefulWidget {
  const DfBannerAdSlot({
    super.key,
    required this.placement,
    this.below,
    this.adUnitId,
    this.adSize = AdSize.banner,
    this.adFactory,
    this.adBuilder,
    this.request = const AdRequest(),
    this.fallbackHeight = 50.0,
  });

  /// Placement name (e.g. 'home_banner').
  final String placement;

  /// Optional widget displayed below the ad, or alone when no ad is loaded
  /// (e.g. an "Upgrade to Pro" or "Remove ads" CTA).
  final Widget? below;

  /// Optional ad unit id. If null, [DfAds.ids.banner] is used.
  final String? adUnitId;

  /// The banner size to request. Defaults to [AdSize.banner].
  final AdSize adSize;

  /// Optional ad factory. If null, [DfAds.factory] is used.
  final DfAdFactory? adFactory;

  /// Optional custom builder for the loaded ad. If null, [AdWidget] is used.
  final Widget Function(BuildContext context, BannerAd ad)? adBuilder;

  /// Ad request parameters.
  final AdRequest request;

  /// Height allocated for [below] when no ad is loaded. Defaults to 50.0.
  final double fallbackHeight;

  @override
  State<DfBannerAdSlot> createState() => _DfBannerAdSlotState();
}

class _DfBannerAdSlotState extends State<DfBannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(DfBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placement != widget.placement ||
        oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.adSize != widget.adSize) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      _loadAd();
    }
  }

  void _loadAd() {
    if (DfAds.isPlatformWeb) return;
    final factory = widget.adFactory ?? DfAds.factory;
    final unitId = widget.adUnitId ?? DfAds.ids.banner;
    _bannerAd = factory.createBanner(
      adUnitId: unitId,
      size: widget.adSize,
      request: widget.request,
      placement: widget.placement,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      final adWidget = SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: widget.adBuilder != null
            ? widget.adBuilder!(context, _bannerAd!)
            : AdWidget(ad: _bannerAd!),
      );

      if (widget.below != null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [adWidget, widget.below!],
        );
      }
      return adWidget;
    }

    if (widget.below != null) {
      return SizedBox(
        height: widget.fallbackHeight,
        child: Center(child: widget.below!),
      );
    }

    return const SizedBox.shrink();
  }
}
