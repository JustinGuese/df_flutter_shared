import 'package:flutter/foundation.dart';

/// User-facing strings for ad components.
///
/// Defaults are English. All placeholder interpolation is done via [fill].
@immutable
class DfAdsStrings {
  const DfAdsStrings({
    this.advertisementEyebrow = 'ADVERTISEMENT',
    this.sponsoredLabel = 'Sponsored',
    this.removeAds = 'Remove ads',
  });

  /// Eyebrow label shown at the top of an ad card.
  final String advertisementEyebrow;

  /// Placeholder label shown while an ad card is loading.
  final String sponsoredLabel;

  /// Generic label for removing ads.
  final String removeAds;

  /// Replaces `{placeholder}` tokens in [template] with entries in [values].
  static String fill(String template, Map<String, Object?> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return result;
  }
}
