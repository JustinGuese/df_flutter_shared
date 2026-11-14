import 'package:flutter/foundation.dart';

import 'df_error_sink.dart';
import 'noop_error_sink.dart';

/// Central error reporting facade for DataFortress applications.
///
/// Call [install] during application startup to wire [FlutterError.onError] and
/// [PlatformDispatcher.onError] to a [DfErrorSink].
abstract final class DfErrorReporting {
  /// The currently active sink.
  static DfErrorSink sink = const NoopErrorSink();
  static FlutterExceptionHandler? _originalFlutterOnError;
  static bool Function(Object exception, StackTrace stackTrace)?
      _originalPlatformOnError;
  static bool _installed = false;

  /// Whether [install] has been called.
  static bool get isInstalled => _installed;

  /// Installs [sink] by wiring [FlutterError.onError] and [PlatformDispatcher.onError].
  ///
  /// If already installed, updates the current sink without overwriting original
  /// platform handlers.
  static void install(DfErrorSink sink, {bool fatalFlutterErrors = false}) {
    DfErrorReporting.sink = sink;
    if (!_installed) {
      _originalFlutterOnError = FlutterError.onError;
      _originalPlatformOnError = PlatformDispatcher.instance.onError;
      _installed = true;
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      _guard(() {
        DfErrorReporting.sink.recordError(
          details.exception,
          details.stack,
          reason: details.context?.toDescription() ?? details.summary.toDescription(),
          fatal: fatalFlutterErrors,
        );
      });
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _guard(() {
        DfErrorReporting.sink.recordError(
          error,
          stack,
          fatal: true,
        );
      });
      return true;
    };
  }

  /// Manually records an error with optional stack trace, reason, and fatal flag.
  static void recordError(
    Object e,
    StackTrace? s, {
    String? reason,
    bool fatal = false,
  }) {
    _guard(() => sink.recordError(e, s, reason: reason, fatal: fatal));
  }

  /// Sets or clears the active user identifier.
  static void setUser(String? id) {
    _guard(() => sink.setUser(id));
  }

  /// Logs a diagnostic message or breadcrumb.
  static void log(String msg) {
    _guard(() => sink.log(msg));
  }

  /// Restores the original error handlers and sets sink back to [NoopErrorSink].
  @visibleForTesting
  static void reset() {
    if (_installed) {
      FlutterError.onError = _originalFlutterOnError;
      PlatformDispatcher.instance.onError = _originalPlatformOnError;
      _originalFlutterOnError = null;
      _originalPlatformOnError = null;
      _installed = false;
    }
    sink = const NoopErrorSink();
  }

  /// Alias for [reset] matching the analytics core testing convention.
  @visibleForTesting
  static void debugReset() => reset();

  static void _guard(void Function() action) {
    try {
      action();
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[df_error_reporting] DfErrorSink threw: $error\n$stack');
      }
    }
  }
}
