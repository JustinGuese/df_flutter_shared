import 'package:flutter/material.dart';

/// A single data item shown in the consent dialog.
class AiConsentDataItem {
  const AiConsentDataItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// App-specific configuration for [AiDataConsentDialog].
class AiConsentConfig {
  const AiConsentConfig({
    required this.introText,
    required this.dataItems,
    required this.processorText,
    required this.privacyPolicyUrl,
  });

  /// Intro paragraph explaining what the app uses AI for.
  final String introText;

  /// List of data items that will be transmitted.
  final List<AiConsentDataItem> dataItems;

  /// Text shown in the highlighted processor box (names DataFortress + Google).
  final String processorText;

  /// URL opened when the user taps "Privacy Policy".
  final String privacyPolicyUrl;
}
