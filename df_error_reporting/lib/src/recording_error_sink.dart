import 'df_error_reporting.dart';
import 'df_error_sink.dart';

/// An error record captured by [RecordingErrorSink].
class RecordedError {
  /// Creates a [RecordedError].
  const RecordedError(
    this.exception,
    this.stackTrace, {
    this.reason,
    this.fatal = false,
  });

  /// The recorded exception or error object.
  final Object exception;

  /// The stack trace associated with the error, if available.
  final StackTrace? stackTrace;

  /// Optional context or description explaining why or where the error occurred.
  final String? reason;

  /// Whether the error was marked as fatal.
  final bool fatal;

  @override
  String toString() =>
      'RecordedError($exception, reason: $reason, fatal: $fatal)';
}

/// A [DfErrorSink] that records all reported errors, user identifiers, and logs
/// in memory for inspection during tests.
class RecordingErrorSink implements DfErrorSink {
  /// Creates a [RecordingErrorSink] and installs it into [DfErrorReporting].
  factory RecordingErrorSink.install({bool fatalFlutterErrors = false}) {
    final sink = RecordingErrorSink();
    DfErrorReporting.install(sink, fatalFlutterErrors: fatalFlutterErrors);
    return sink;
  }

  /// Creates an empty [RecordingErrorSink].
  RecordingErrorSink();

  /// All errors recorded by this sink.
  final List<RecordedError> errors = [];

  /// All user IDs set on this sink.
  final List<String?> userIds = [];

  /// All breadcrumb messages logged to this sink.
  final List<String> logs = [];

  @override
  void recordError(
    Object e,
    StackTrace? s, {
    String? reason,
    bool fatal = false,
  }) {
    errors.add(RecordedError(e, s, reason: reason, fatal: fatal));
  }

  @override
  void setUser(String? id) {
    userIds.add(id);
  }

  @override
  void log(String msg) {
    logs.add(msg);
  }

  /// Clears all recorded errors, user IDs, and logs.
  void clear() {
    errors.clear();
    userIds.clear();
    logs.clear();
  }
}
