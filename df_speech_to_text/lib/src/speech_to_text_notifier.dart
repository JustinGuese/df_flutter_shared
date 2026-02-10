import 'dart:async' show Timer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'speech_to_text_config.dart';
import 'widgets/microphone_permission_dialog.dart';

class SpeechToTextState {
  SpeechToTextState({
    this.isAvailable = true, // Assume available until proven otherwise
    this.isListening = false,
    this.recognizedWords = '',
    this.error,
    this.isInitialized = false,
  });

  final bool isAvailable;
  final bool isListening;
  final String recognizedWords;
  final String? error;
  final bool isInitialized;

  SpeechToTextState copyWith({
    bool? isAvailable,
    bool? isListening,
    String? recognizedWords,
    Object? error = _sentinel,
    bool? isInitialized,
  }) {
    return SpeechToTextState(
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      recognizedWords: recognizedWords ?? this.recognizedWords,
      error: identical(error, _sentinel) ? this.error : error as String?,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

const _sentinel = Object();

final speechToTextProvider =
    NotifierProvider<SpeechToTextNotifier, SpeechToTextState>(
      SpeechToTextNotifier.new,
    );

class SpeechToTextNotifier extends Notifier<SpeechToTextState> {
  stt.SpeechToText? _speech;
  void Function(SpeechRecognitionResult result)? _engineResultHandler;

  /// Finalized utterance segments for this session. Each segment corresponds
  /// to a `finalResult` from the engine.
  final List<String> _segments = [];

  /// Latest non-final partial text for live preview.
  String _currentPartial = '';

  /// Whether the user explicitly requested to stop listening.
  bool _userRequestedStop = false;

  /// How many times we've restarted listening in this session to simulate
  /// continuous dictation.
  int _restartCount = 0;

  /// Flag set when a final result arrives and we want to restart as soon as
  /// the engine transitions to `notListening`.
  bool _shouldRestart = false;

  /// Safety timer to finalize text if we requested a stop but never receive
  /// a final result from the engine.
  Timer? _finalizeTimer;


  @override
  SpeechToTextState build() {
    // Don't initialize eagerly - wait until user actually wants to use it
    // This prevents iOS permission dialogs from appearing before the app dialog
    return SpeechToTextState();
  }

  /// Initialize speech recognition lazily when needed.
  /// This is called only after permissions are granted to avoid triggering
  /// iOS permission dialogs prematurely.
  Future<void> _initializeIfNeeded() async {
    if (_speech != null && state.isInitialized) {
      return; // Already initialized
    }

    _speech = stt.SpeechToText();
    final available = await _speech!.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );

    state = state.copyWith(isAvailable: available, isInitialized: true);
  }

  void _onStatus(String status) {
    final isListening = status == 'listening';
    state = state.copyWith(isListening: isListening);

    if (!isListening && !_userRequestedStop && _shouldRestart) {
      // Previous session ended naturally after silence; start a new one to keep
      // dictation feeling continuous.
      _shouldRestart = false;
      _startEngineListening();
    }
  }

  void _onError(SpeechRecognitionError error) {
    state = state.copyWith(error: error.errorMsg, isListening: false);
  }

  bool _endsWithSentencePunctuation(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final lastChar = trimmed[trimmed.length - 1];
    return lastChar == '.' || lastChar == '!' || lastChar == '?';
  }

  /// Capitalize the first letter of the text.
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return text;
    final leadingWhitespaceLength = text.length - trimmed.length;
    final leadingWhitespace = text.substring(0, leadingWhitespaceLength);
    final first = trimmed[0].toUpperCase();
    if (trimmed.length == 1) {
      return '$leadingWhitespace$first';
    }
    return '$leadingWhitespace$first${trimmed.substring(1)}';
  }

  /// Capitalize letters after every sentence-ending punctuation mark (.!?)
  /// and also capitalize the very first letter.
  String _capitalizeSentences(String text) {
    if (text.isEmpty) return text;
    final buffer = StringBuffer();
    bool capitalizeNext = true;
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (capitalizeNext && RegExp(r'[a-z]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
      }
      if ('.!?'.contains(char)) {
        capitalizeNext = true;
      }
    }
    return buffer.toString();
  }

  /// Ensure the segment ends with sentence punctuation. If not, append a period.
  String _ensureTrailingPunctuation(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    if (_endsWithSentencePunctuation(trimmed)) return trimmed;
    return '$trimmed.';
  }

  /// Clean up whitespace: collapse multiple spaces, remove space before punctuation.
  String _cleanupWhitespace(String text) {
    var result = text.replaceAll(RegExp(r'\s+'), ' ');
    result = result.replaceAll(RegExp(r'\s+([.!?,;:])'), r'$1');
    return result.trim();
  }

  void _updatePreviewFromBuffers() {
    final parts = <String>[];
    if (_segments.isNotEmpty) {
      parts.addAll(_segments);
    }
    if (_currentPartial.isNotEmpty) {
      // Capitalize partial if the previous segment ended with punctuation
      var partial = _currentPartial;
      if (_segments.isNotEmpty &&
          _endsWithSentencePunctuation(_segments.last)) {
        partial = _capitalize(partial);
      }
      parts.add(partial);
    }
    final preview = parts.join(' ').trim();
    state = state.copyWith(recognizedWords: preview);
  }

  void _resetSessionBuffers() {
    _segments.clear();
    _currentPartial = '';
    _userRequestedStop = false;
    _restartCount = 0;
    _shouldRestart = false;
    _finalizeTimer?.cancel();
    _finalizeTimer = null;
  }

  void _finalize() {
    _finalizeTimer?.cancel();
    _finalizeTimer = null;

    var full = _segments.join(' ').trim();
    if (full.isEmpty && _currentPartial.isNotEmpty) {
      full = _currentPartial.trim();
    }

    if (full.isEmpty) {
      state = state.copyWith(recognizedWords: '');
      _resetSessionBuffers();
      return;
    }

    // Ensure trailing punctuation, capitalize after all sentence boundaries,
    // and clean up whitespace artifacts.
    full = _ensureTrailingPunctuation(full);
    full = _capitalizeSentences(full);
    full = _cleanupWhitespace(full);

    // Store the finalized text as a single segment for any later reads this
    // session. Do NOT reset _userRequestedStop or _shouldRestart here — those
    // are session lifecycle flags managed by stopListening / _resetSessionBuffers.
    // Resetting them here caused late engine results to be processed and
    // duplicate text.
    _segments
      ..clear()
      ..add(full);
    _currentPartial = '';

    state = state.copyWith(recognizedWords: full);
  }

  void _onResult(SpeechRecognitionResult result) {
    // After the user tapped stop, ignore any late results from the engine.
    // stopListening() already called _finalize() with whatever we had.
    if (_userRequestedStop) return;

    final config = ref.read(speechToTextConfigProvider);
    final words = result.recognizedWords.trim();
    if (result.finalResult) {
      if (words.isNotEmpty) {
        // Each finalized segment gets punctuation and capitalization.
        // This makes the text read properly during continuous dictation.
        var segment = _ensureTrailingPunctuation(words);
        segment = _capitalize(segment);
        _segments.add(segment);
      }
      _currentPartial = '';

      if (_userRequestedStop || _restartCount >= config.maxRestarts) {
        _finalize();
      } else {
        _restartCount++;
        _shouldRestart = true;
      }
    } else {
      // Non-final partial: just update the live preview.
      _currentPartial = words;
    }

    _updatePreviewFromBuffers();
  }

  /// Check if all required permissions for speech-to-text are granted.
  Future<bool> checkMicrophonePermission() async {
    if (kIsWeb) {
      return true; // Web handles permissions via browser
    }

    if (Platform.isIOS) {
      final micStatus = await Permission.microphone.status;
      debugPrint('🎤 checkMicrophonePermission (iOS): mic=$micStatus');
      return micStatus.isGranted;
    }

    final micStatus = await Permission.microphone.status;
    debugPrint('🎤 checkMicrophonePermission (Android): mic status = $micStatus');
    if (!micStatus.isGranted) {
      return false;
    }

    return true;
  }

  /// Request all required permissions for speech-to-text.
  Future<bool> requestMicrophonePermission() async {
    if (kIsWeb) {
      return true; // Web handles permissions via browser
    }

    if (Platform.isIOS) {
      debugPrint('🎤 requestMicrophonePermission (iOS): requesting microphone...');
      final micStatus = await Permission.microphone.request();
      debugPrint('🎤 requestMicrophonePermission (iOS): mic=$micStatus');

      if (micStatus.isPermanentlyDenied) {
        debugPrint(
          '🎤 requestMicrophonePermission (iOS): permanently denied, opening settings...',
        );
        await openAppSettings();
        return false;
      }

      return micStatus.isGranted;
    }

    debugPrint('🎤 requestMicrophonePermission (Android): requesting microphone...');
    final micStatus = await Permission.microphone.request();
    debugPrint('🎤 requestMicrophonePermission (Android): mic result = $micStatus');

    if (micStatus.isPermanentlyDenied) {
      debugPrint(
        '🎤 requestMicrophonePermission (Android): mic permanently denied, opening settings...',
      );
      await openAppSettings();
      return false;
    }

    if (!micStatus.isGranted) {
      debugPrint(
        '🎤 requestMicrophonePermission (Android): mic not granted, returning false',
      );
      return false;
    }

    return true;
  }

  /// Check and request all required permissions if needed.
  Future<bool> ensureMicrophonePermission() async {
    final isGranted = await checkMicrophonePermission();
    if (isGranted) {
      return true;
    }
    return await requestMicrophonePermission();
  }

  /// Start listening for speech input.
  Future<void> startListening({void Function(String words)? onResult}) async {
    if (state.isListening) {
      return;
    }

    await _initializeIfNeeded();

    if (_speech == null || !state.isAvailable) {
      state = state.copyWith(
        error: 'Speech recognition is not available on this device',
        isListening: false,
      );
      return;
    }

    _resetSessionBuffers();
    state = state.copyWith(recognizedWords: '', error: null);

    void handleResult(SpeechRecognitionResult result) {
      _onResult(result);
      if (onResult != null && result.finalResult && _userRequestedStop) {
        final cleaned = state.recognizedWords.trim();
        if (cleaned.isNotEmpty) {
          onResult(cleaned);
        }
      }
    }

    _engineResultHandler = handleResult;
    await _startEngineListening();
  }

  Future<void> _startEngineListening() async {
    if (_speech == null || _engineResultHandler == null) return;

    final config = ref.read(speechToTextConfigProvider);
    await _speech!.listen(
      onResult: _engineResultHandler!,
      listenFor: config.listenDuration,
      pauseFor: config.pauseDuration,
      localeId: config.localeId,
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        autoPunctuation: true,
        enableHapticFeedback: false,
      ),
    );
  }

  /// High-level helper that handles permission flow, optional app-level
  /// explanation dialog, and starts listening in one call.
  ///
  /// Returns `true` if listening was started, `false` otherwise.
  Future<bool> ensurePermissionAndStartListening(
    BuildContext context, {
    void Function(String words)? onResult,
    VoidCallback? onListeningStarted,
    MicrophonePermissionDialogConfig? dialogConfig,
  }) async {
    var hasPermission = await checkMicrophonePermission();

    if (!hasPermission) {
      // ignore: use_build_context_synchronously
      await MicrophonePermissionDialog.show(context, config: dialogConfig);

      final permissionGranted = await requestMicrophonePermission();
      if (!permissionGranted) {
        return false;
      }
      hasPermission = true;
    }

    if (!hasPermission) {
      return false;
    }

    await startListening(onResult: onResult);
    onListeningStarted?.call();
    return true;
  }

  Future<void> stopListening() async {
    if (_speech == null) {
      return;
    }

    // User explicitly tapped "stop" in the UI. We want to:
    // - Immediately prevent any automatic restarts
    // - Stop the engine
    // - Finalize whatever text we have so far
    // - Ensure state reflects that we're no longer listening
    _userRequestedStop = true;
    _shouldRestart = false;

    _finalizeTimer?.cancel();
    _finalizeTimer = null;

    if (state.isListening) {
      await _speech!.stop();
    } else {
      await _speech!.cancel();
    }

    _finalize();

    // Make sure provider consumers see that listening has fully stopped.
    state = state.copyWith(isListening: false);
  }

  Future<void> cancelListening() async {
    if (_speech == null) {
      return;
    }

    await _speech!.cancel();
    state = state.copyWith(
      isListening: false,
      recognizedWords: state.recognizedWords,
    );
    _resetSessionBuffers();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearRecognizedWords() {
    state = state.copyWith(recognizedWords: '');
    _resetSessionBuffers();
  }
}
