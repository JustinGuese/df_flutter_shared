import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for speech-to-text behavior.
/// Override [speechToTextConfigProvider] in your app to customize.
@immutable
class SpeechToTextConfig {
  const SpeechToTextConfig({
    this.listenDuration = const Duration(seconds: 60),
    this.pauseDuration = const Duration(seconds: 3),
    this.maxRestarts = 20,
    this.finalizeTimeout = const Duration(milliseconds: 600),
    this.localeId,
  });

  final Duration listenDuration;
  final Duration pauseDuration;
  final int maxRestarts;
  final Duration finalizeTimeout;

  /// Optional locale for speech recognition (e.g. 'de_DE', 'en_US').
  /// When null, uses the device default.
  final String? localeId;
}

final speechToTextConfigProvider =
    Provider<SpeechToTextConfig>((ref) => const SpeechToTextConfig());
