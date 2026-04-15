import 'package:flutter/material.dart';

/// All copy and visual configuration for the paywall widgets.
/// Create one instance per app and pass it to every paywall component.
class PaywallConfig {
  /// Product name shown in headings (e.g. "NaviCare Plus").
  final String productName;

  /// Emoji or short string shown in the hero circle (e.g. "⭐").
  final String heroEmoji;

  /// Trial headline shown below the product name (e.g. "7 Tage kostenlos testen").
  final String trialHeadline;

  /// Price label (e.g. "9,99 €/Monat").
  final String priceLabel;

  /// Cancellation note shown next to the price (e.g. "Jederzeit kündbar").
  final String cancellationNote;

  /// Feature rows shown in the feature list.
  final List<String> features;

  /// Credibility line shown below features — use verifiable claims, not fake numbers.
  final String credibilityText;

  /// CTA button text (e.g. "Jetzt kostenlos starten →").
  final String ctaText;

  /// Dismiss link text — keep neutral, no guilt (e.g. "Später entscheiden").
  final String dismissText;

  /// Primary gradient colours for hero sections.
  final List<Color> gradient;

  /// Accent colour for checkmarks, buttons, and badges.
  final Color accentColor;

  const PaywallConfig({
    required this.productName,
    required this.heroEmoji,
    required this.trialHeadline,
    required this.priceLabel,
    required this.cancellationNote,
    required this.features,
    required this.credibilityText,
    this.ctaText = 'Jetzt kostenlos starten →',
    this.dismissText = 'Später entscheiden',
    this.gradient = const [Color(0xFF0E6B82), Color(0xFF0C445A)],
    this.accentColor = const Color(0xFF0E6B82),
  });
}
