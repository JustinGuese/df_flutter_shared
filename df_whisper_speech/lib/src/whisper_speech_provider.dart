import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import 'whisper_speech_config.dart';
import 'recording_io/recording_io.dart';

/// Status of the speech recording and transcription pipeline.
enum WhisperSpeechStatus { idle, recording, transcribing }

/// State of the Whisper speech provider.
///
/// Tracks recording duration, transcribed text, errors, and service availability.
class WhisperSpeechState {
  const WhisperSpeechState({
    this.status = WhisperSpeechStatus.idle,
    this.transcribedText = '',
    this.error,
    this.recordingDuration = Duration.zero,
    this.isBlocked = false,
  });

  final WhisperSpeechStatus status;
  final String transcribedText;
  final String? error;
  final Duration recordingDuration;

  /// True while the record button is temporarily disabled after a service error.
  final bool isBlocked;

  WhisperSpeechState copyWith({
    WhisperSpeechStatus? status,
    String? transcribedText,
    String? error,
    Duration? recordingDuration,
    bool? isBlocked,
  }) {
    return WhisperSpeechState(
      status: status ?? this.status,
      transcribedText: transcribedText ?? this.transcribedText,
      error: error,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

/// Override this in [ProviderScope] with your authenticated [Dio] client.
///
/// Example:
/// ```dart
/// whisperDioProvider.overrideWith((ref) => ref.watch(apiClientProvider))
/// ```
final whisperDioProvider = Provider<Dio>((ref) {
  throw UnimplementedError(
    'whisperDioProvider must be overridden with an authenticated Dio client.',
  );
});

/// Notifier that handles recording audio to a temporary file and streaming it
/// to the backend Whisper transcription API via SSE.
class WhisperSpeechNotifier extends Notifier<WhisperSpeechState> {
  final _record = AudioRecorder();
  Timer? _durationTimer;
  Timer? _blockTimer;
  CancelToken? _cancelToken;
  String? _currentRecordingPath;

  Dio get _dio => ref.read(whisperDioProvider);

  @override
  WhisperSpeechState build() {
    ref.onDispose(_cleanup);
    return const WhisperSpeechState();
  }

  Future<void> startRecording() async {
    if (state.isBlocked) return;
    if (state.status == WhisperSpeechStatus.recording ||
        state.status == WhisperSpeechStatus.transcribing) {
      return;
    }

    try {
      final hasPermission = await _record.hasPermission();
      if (!hasPermission) {
        state = state.copyWith(
          status: WhisperSpeechStatus.idle,
          error: 'Microphone permission denied. Please enable it in settings.',
        );
        return;
      }

      final filePath = await getRecordingPath();

      await _record.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      _startDurationTimer();

      state = state.copyWith(
        status: WhisperSpeechStatus.recording,
        transcribedText: '',
        error: null,
        recordingDuration: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(
        status: WhisperSpeechStatus.idle,
        error: 'Failed to start recording: $e',
      );
    }
  }

  Future<String?> stopRecording() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;
      if (!await _record.isRecording()) {
        return _currentRecordingPath;
      }

      final path = await _record.stop();
      _currentRecordingPath = path;
      return path ?? _currentRecordingPath;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to stop recording: $e',
      );
      return null;
    }
  }

  Future<void> stopAndTranscribe() async {
    if (state.status != WhisperSpeechStatus.recording) {
      return;
    }

    final path = await stopRecording();
    if (path == null) {
      state = state.copyWith(
        status: WhisperSpeechStatus.idle,
        error: 'No audio file to transcribe.',
      );
      return;
    }

    state = state.copyWith(
      status: WhisperSpeechStatus.transcribing,
      error: null,
    );

    await _transcribeInternal(path);
  }

  Future<void> _transcribeInternal(String recordingPath) async {
    _cancelToken = CancelToken();
    final cancelToken = _cancelToken!;
    final config = ref.read(whisperSpeechConfigProvider);

    try {
      final bytes = await readRecordingBytes(recordingPath);
      final filename = kIsWeb ? 'recording.webm' : 'recording.m4a';
      final contentType =
          kIsWeb ? DioMediaType('audio', 'webm') : DioMediaType('audio', 'mp4');
      final formData = FormData.fromMap({
        'audio': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: contentType,
        ),
      });

      final response = await _dio.post<ResponseBody>(
        config.transcribeEndpoint,
        data: formData,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: config.transcriptionReceiveTimeout,
          headers: {
            'Accept': 'text/event-stream',
          },
        ),
        cancelToken: cancelToken,
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw Exception('No response stream from transcription endpoint.');
      }

      final utf8Stream = stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      final buffer = StringBuffer();
      String? currentEvent;

      final timeout = config.transcriptionTimeout;
      final completer = Completer<void>();

      final sub = utf8Stream.listen(
        (line) {
          if (line.startsWith('event:')) {
            currentEvent = line.substring('event:'.length).trim();
          } else if (line.startsWith('data:')) {
            final data = line.substring('data:'.length).trim();
            if (currentEvent == 'token') {
              buffer.write(data);
              final text = buffer.toString();
              state = state.copyWith(transcribedText: text);
            } else if (currentEvent == 'end') {
              // End event can carry final metadata; we ignore for now.
            }
          } else if (line.isEmpty) {
            // SSE event separator, ignore.
          }
        },
        onError: (error, stack) {
          if (!completer.isCompleted) {
            completer.completeError(error, stack);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        cancelOnError: true,
      );

      try {
        await completer.future.timeout(timeout);
      } on TimeoutException {
        await sub.cancel();
        throw Exception('timeout');
      } finally {
        await sub.cancel();
      }

      state = state.copyWith(status: WhisperSpeechStatus.idle);
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        // Swallow cancellation errors; state reset happens in cancel().
        return;
      }
      final isServiceError =
          e is DioException &&
              (e.type == DioExceptionType.receiveTimeout ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.connectionError) ||
          e.toString().contains('timeout');
      final errorMessage = isServiceError
          ? 'Sorry, our speech service is not available right now, please type your message.'
          : 'Transcription failed: $e';
      state = state.copyWith(
        status: WhisperSpeechStatus.idle,
        error: errorMessage,
        isBlocked: isServiceError,
      );
      if (isServiceError) {
        _blockTimer?.cancel();
        _blockTimer = Timer(config.errorBlockDuration, () {
          state = state.copyWith(isBlocked: false, error: null);
        });
      }
    } finally {
      _cancelToken = null;
      _deleteRecording();
    }
  }

  Future<void> cancel() async {
    _durationTimer?.cancel();
    _durationTimer = null;
    _blockTimer?.cancel();
    _blockTimer = null;

    if (await _record.isRecording()) {
      await _record.stop();
    }

    _cancelToken?.cancel('Cancelled by user');
    _cancelToken = null;

    _deleteRecording();

    state = state.copyWith(
      status: WhisperSpeechStatus.idle,
      transcribedText: '',
      error: null,
      recordingDuration: Duration.zero,
    );
  }

  void reset() {
    state = const WhisperSpeechState();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.recordingDuration + const Duration(seconds: 1);
      state = state.copyWith(recordingDuration: next);
    });
  }

  void _deleteRecording() {
    deleteRecording(_currentRecordingPath);
    _currentRecordingPath = null;
  }

  Future<void> _cleanup() async {
    _durationTimer?.cancel();
    _durationTimer = null;
    _blockTimer?.cancel();
    _blockTimer = null;
    _cancelToken?.cancel('disposed');
    _cancelToken = null;
    if (await _record.isRecording()) {
      await _record.stop();
    }
    _deleteRecording();
  }
}

final whisperSpeechProvider =
    NotifierProvider<WhisperSpeechNotifier, WhisperSpeechState>(
  WhisperSpeechNotifier.new,
);
