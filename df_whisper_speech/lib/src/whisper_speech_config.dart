import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for Whisper speech-to-text backend communication.
///
/// Customize timeouts, endpoints, and error handling behavior. These defaults
/// match the standard psychdiary backend configuration.
@immutable
class WhisperSpeechConfig {
  const WhisperSpeechConfig({
    this.transcribeEndpoint = '/speech/transcribe/stream',
    this.transcriptionTimeout = const Duration(seconds: 60),
    this.transcriptionReceiveTimeout = const Duration(seconds: 30),
    this.errorBlockDuration = const Duration(seconds: 30),
  });

  /// Backend endpoint for SSE streaming transcription.
  /// Default: `/speech/transcribe/stream`
  final String transcribeEndpoint;

  /// Total timeout for the entire transcription stream.
  /// If the stream doesn't complete within this duration, transcription fails.
  /// Default: 60 seconds
  final Duration transcriptionTimeout;

  /// Per-request socket receive timeout for the HTTP call.
  /// Fails faster if the network is hung; allows recovery if the stream stalls.
  /// Default: 30 seconds
  final Duration transcriptionReceiveTimeout;

  /// How long the record button stays disabled after a service error.
  /// Prevents rapid retry hammering on unavailable services.
  /// Default: 30 seconds
  final Duration errorBlockDuration;
}

/// Override this in [ProviderScope] to use custom timeouts or endpoint.
/// Defaults match the standard psychdiary backend configuration.
final whisperSpeechConfigProvider = Provider<WhisperSpeechConfig>(
  (_) => const WhisperSpeechConfig(),
);
