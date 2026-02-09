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
  });

  final Duration listenDuration;
  final Duration pauseDuration;
  final int maxRestarts;
  final Duration finalizeTimeout;
}

final speechToTextConfigProvider =
    Provider<SpeechToTextConfig>((ref) => const SpeechToTextConfig());
