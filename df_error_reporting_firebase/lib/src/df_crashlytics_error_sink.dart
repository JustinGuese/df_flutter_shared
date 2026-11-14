import 'dart:async';

import 'package:df_error_reporting/df_error_reporting.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// The Firebase Crashlytics calls [DfCrashlyticsErrorSink] makes.
///
/// This seam allows unit tests to supply fakes without requiring an initialized
/// native Firebase app.
abstract interface class DfCrashlyticsCalls {
  /// Records a non-fatal or fatal error with optional stack trace and reason.
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  });

  /// Sets the user identifier, or clears it if an empty string.
  Future<void> setUserIdentifier(String identifier);

  /// Logs a message to be included in subsequent crash reports.
  Future<void> log(String message);
}

/// Default implementation forwarding to a [FirebaseCrashlytics] instance.
class _DefaultFirebaseCrashlyticsCalls implements DfCrashlyticsCalls {
  _DefaultFirebaseCrashlyticsCalls([FirebaseCrashlytics? crashlytics])
    : _crashlytics = crashlytics;

  final FirebaseCrashlytics? _crashlytics;

  FirebaseCrashlytics get _instance =>
      _crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) {
    return _instance.recordError(
      exception,
      stack,
      reason: reason,
      information: information,
      printDetails: printDetails,
      fatal: fatal,
    );
  }

  @override
  Future<void> setUserIdentifier(String identifier) {
    return _instance.setUserIdentifier(identifier);
  }

  @override
  Future<void> log(String message) {
    return _instance.log(message);
  }
}

/// A [DfErrorSink] implementation that forwards errors, logs, and user IDs
/// to Firebase Crashlytics.
class DfCrashlyticsErrorSink implements DfErrorSink {
  /// Creates a Firebase Crashlytics error sink.
  ///
  /// By default, delegates to [FirebaseCrashlytics.instance]. An explicit
  /// [crashlytics] instance or a custom [calls] seam can be provided for
  /// secondary Firebase apps or testing.
  DfCrashlyticsErrorSink({
    FirebaseCrashlytics? crashlytics,
    @visibleForTesting DfCrashlyticsCalls? calls,
  }) : _calls = calls ?? _DefaultFirebaseCrashlyticsCalls(crashlytics);

  final DfCrashlyticsCalls _calls;

  @override
  void recordError(
    Object e,
    StackTrace? s, {
    String? reason,
    bool fatal = false,
  }) {
    _send(
      'recordError',
      () => _calls.recordError(e, s, reason: reason, fatal: fatal),
    );
  }

  @override
  void setUser(String? id) {
    _send('setUser', () => _calls.setUserIdentifier(id ?? ''));
  }

  @override
  void log(String msg) {
    _send('log', () => _calls.log(msg));
  }

  /// Crashlytics calls are fire-and-forget, but any asynchronous or synchronous
  /// failures are caught so error reporting failures never crash the app.
  void _send(String label, Future<void> Function() action) {
    try {
      unawaited(
        action().catchError((Object e, StackTrace s) {
          if (kDebugMode) {
            debugPrint('[df_error_reporting_firebase] $label failed: $e');
          }
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[df_error_reporting_firebase] $label threw synchronously: $e',
        );
      }
    }
  }
}

/// Alias for [DfCrashlyticsErrorSink].
typedef DfFirebaseCrashlyticsSink = DfCrashlyticsErrorSink;
