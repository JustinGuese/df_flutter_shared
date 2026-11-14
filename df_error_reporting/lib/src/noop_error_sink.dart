import 'df_error_sink.dart';

/// A [DfErrorSink] that silently drops all errors, user identifiers, and logs.
///
/// Guaranteed never to throw.
class NoopErrorSink implements DfErrorSink {
  /// Creates a [NoopErrorSink].
  const NoopErrorSink();

  @override
  void recordError(
    Object e,
    StackTrace? s, {
    String? reason,
    bool fatal = false,
  }) {}

  @override
  void setUser(String? id) {}

  @override
  void log(String msg) {}
}
