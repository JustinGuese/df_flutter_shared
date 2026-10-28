import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_factory.dart';
import 'ads_strings.dart';
import 'df_ads.dart';

/// A swipeable ad card: a medium-rectangle ad framed with DF token styling.
///
/// The ad is only requested once the card is at the front ([isFront] == true)
/// to avoid platform views moving across card stack layers.
/// On failure or on web, renders [fallback].
class DfCardAd extends StatefulWidget {
  const DfCardAd({
    super.key,
    required this.placement,
    required this.isFront,
    required this.fallback,
    this.action,
    this.adUnitId,
    this.adFactory,
    this.adBuilder,
    this.strings,
    this.request = const AdRequest(),
  });

  /// Placement name (e.g. 'swipe_ad_card').
  final String placement;

  /// Whether this card is at the front of the stack.
  final bool isFront;

  /// Fallback builder rendered if ad fails to load or when running on web.
  final WidgetBuilder fallback;

  /// Optional action widget rendered at the bottom (e.g. "Remove ads" CTA).
  final Widget? action;

  /// Optional ad unit id. If null, [DfAds.ids.banner] is used.
  final String? adUnitId;

  /// Optional ad factory. If null, [DfAds.factory] is used.
  final DfAdFactory? adFactory;

  /// Optional custom builder for the loaded ad. If null, [AdWidget] is used.
  final Widget Function(BuildContext context, BannerAd ad)? adBuilder;

  /// Optional strings override. If null, [DfAds.strings] is used.
  final DfAdsStrings? strings;

  /// Ad request parameters.
  final AdRequest request;

  @override
  State<DfCardAd> createState() => _DfCardAdState();
}

class _DfCardAdState extends State<DfCardAd> {
  BannerAd? _ad;
  bool _loaded = false;
  late bool _failed;

  @override
  void initState() {
    super.initState();
    _failed = DfAds.isPlatformWeb;
    _maybeLoad();
  }

  @override
  void didUpdateWidget(DfCardAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLoad();
  }

  void _maybeLoad() {
    if (!widget.isFront || _ad != null || _failed) return;
    if (DfAds.isPlatformWeb) {
      if (!_failed && mounted) {
        setState(() => _failed = true);
      }
      return;
    }

    final factory = widget.adFactory ?? DfAds.factory;
    final adUnitId = widget.adUnitId ?? DfAds.ids.banner;
    _ad = factory.createBanner(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle,
      request: widget.request,
      placement: widget.placement,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _ad = null;
              _failed = true;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.fallback(context);
    }

    final df = context.df;
    final text = Theme.of(context).textTheme;
    final strings = widget.strings ?? DfAds.strings;
    final ad = _ad;

    return Container(
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: df.shape.radiusXl,
        border: Border.all(color: df.colors.hairline),
        boxShadow: df.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(df.spacing.mdPlus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.advertisementEyebrow, style: df.eyebrow),
          Expanded(
            child: Center(
              child: SizedBox(
                width: AdSize.mediumRectangle.width.toDouble(),
                height: AdSize.mediumRectangle.height.toDouble(),
                child: _loaded && ad != null
                    ? (widget.adBuilder != null
                          ? widget.adBuilder!(context, ad)
                          : AdWidget(ad: ad))
                    : Center(
                        child: Text(
                          strings.sponsoredLabel,
                          style: text.labelMedium?.copyWith(
                            color: df.colors.textTertiary,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (widget.action != null)
            Align(alignment: Alignment.centerLeft, child: widget.action!),
        ],
      ),
    );
  }
}
