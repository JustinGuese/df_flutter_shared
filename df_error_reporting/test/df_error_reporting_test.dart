import 'package:df_error_reporting/df_error_reporting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingSink implements DfErrorSink {
  @override
  void recordError(
    Object e,
    StackTrace? s, {
    String? reason,
    bool fatal = false,
  }) {
    throw Exception('sink error');
  }

  @override
  void setUser(String? id) {
    throw Exception('sink user error');
  }

  @override
  void log(String msg) {
    throw Exception('sink log error');
  }
}

void main() {
  tearDown(DfErrorReporting.reset);

  test('install routes a thrown framework error to the sink', () {
    final sink = RecordingErrorSink.install();
    final exception = StateError('framework build error');
    final stack = StackTrace.current;

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: exception,
        stack: stack,
        context: ErrorDescription('building MyWidget'),
      ),
    );

    expect(sink.errors, hasLength(1));
    final recorded = sink.errors.single;
    expect(recorded.exception, exception);
    expect(recorded.stackTrace, stack);
    expect(recorded.reason, contains('building MyWidget'));
    expect(recorded.fatal, isFalse);
  });

  test('NoopErrorSink never throws on recordError, setUser, or log', () {
    const sink = NoopErrorSink();

    expect(
      () => sink.recordError(
        Exception('fail'),
        StackTrace.empty,
        reason: 'test',
        fatal: true,
      ),
      returnsNormally,
    );
    expect(() => sink.setUser('user-123'), returnsNormally);
    expect(() => sink.setUser(null), returnsNormally);
    expect(() => sink.log('something happened'), returnsNormally);
  });

  test('wires platform dispatcher onError and handles sink exceptions safely', () {
    final sink = RecordingErrorSink.install();
    final error = Exception('uncaught async error');
    final stack = StackTrace.current;

    final handled = PlatformDispatcher.instance.onError?.call(error, stack);

    expect(handled, isTrue);
    expect(sink.errors, hasLength(1));
    expect(sink.errors.single.exception, error);
    expect(sink.errors.single.fatal, isTrue);

    // Fail-soft: a broken sink never throws into the caller
    DfErrorReporting.sink = _ThrowingSink();
    expect(
      () => DfErrorReporting.recordError(Exception('boom'), null),
      returnsNormally,
    );
    expect(() => DfErrorReporting.setUser('user'), returnsNormally);
    expect(() => DfErrorReporting.log('log'), returnsNormally);
  });
}
