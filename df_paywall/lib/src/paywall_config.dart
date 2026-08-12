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

  /// Shown when [onCta]/[onUpgrade] throws. Null falls back to the theme.
  final String checkoutErrorText;

  /// Shown when opening the billing portal throws.
  final String portalErrorText;

  /// Label prefixed to the current period's end date (e.g. "Next billing date: 12.08.2026").
  final String nextBillingLabel;

  /// Hint text below the "manage subscription" button.
  final String portalHintText;

  /// Confirmation heading for a subscribed user. `{product}` is replaced with
  /// [productName].
  final String memberHeadline;

  /// Trial countdown. `{days}` is replaced with the number of days remaining.
  final String trialDaysRemainingLabel;

  /// Prefix for the trial end date, rendered as `'<label>: <date>'`.
  final String trialEndsLabel;

  /// Label on the button that opens the billing portal.
  final String manageSubscriptionLabel;

  /// Caption above the price, explaining when billing starts.
  final String afterTrialLabel;

  /// Heading over the feature list. `{product}` is replaced with [productName].
  final String featuresHeadline;

  /// Primary gradient colours for hero sections. Null uses the theme's `'hero'` gradient.
  final List<Color>? gradient;

  /// Accent colour for checkmarks, buttons, and badges. Null uses the theme's brand colour.
  final Color? accentColor;

  const PaywallConfig({
    required this.productName,
    required this.heroEmoji,
    required this.trialHeadline,
    required this.priceLabel,
    required this.cancellationNote,
    required this.features,
    required this.credibilityText,
    this.ctaText = 'Start free trial →',
    this.dismissText = 'Maybe later',
    this.checkoutErrorText =
        'Could not open the payment page. Please try again.',
    this.portalErrorText =
        'Could not open the billing portal. Please try again.',
    this.nextBillingLabel = 'Next billing date',
    this.portalHintText =
        'Manage cancellation, payment method and invoices in the billing portal.',
    this.memberHeadline = 'You are a {product} member',
    this.trialDaysRemainingLabel = '{days} days left in your free trial',
    this.trialEndsLabel = 'Trial ends',
    this.manageSubscriptionLabel = 'Manage subscription & payment',
    this.afterTrialLabel = 'After the free trial',
    this.featuresHeadline = 'Included in {product}',
    this.gradient,
    this.accentColor,
  });

  /// Substitutes `{product}` and `{days}` in the copy above.
  ///
  /// Placeholders rather than string interpolation at the call site, so a
  /// translated string can put the product name or count wherever its grammar
  /// needs it.
  String fill(String template, {int? days}) => template
      .replaceAll('{product}', productName)
      .replaceAll('{days}', days?.toString() ?? '');
}
