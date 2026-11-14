import 'package:df_error_reporting_firebase/df_error_reporting_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordedError {
  _RecordedError(this.exception, this.stack, this.reason, this.fatal);

  final Object exception;
  final StackTrace? stack;
  final dynamic reason;
  final bool fatal;
}

class _FakeCrashlyticsCalls implements DfCrashlyticsCalls {
  final errors = <_RecordedError>[];
  final userIdentifiers = <String>[];
  final logs = <String>[];

  bool shouldThrowSync = false;
  bool shouldThrowAsync = false;

  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) async {
    if (shouldThrowSync) throw Exception('synchronous failure');
    if (shouldThrowAsync) return Future.error(Exception('async failure'));
    errors.add(_RecordedError(exception, stack, reason, fatal));
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    if (shouldThrowSync) throw Exception('synchronous failure');
    if (shouldThrowAsync) return Future.error(Exception('async failure'));
    userIdentifiers.add(identifier);
  }

  @override
  Future<void> log(String message) async {
    if (shouldThrowSync) throw Exception('synchronous failure');
    if (shouldThrowAsync) return Future.error(Exception('async failure'));
    logs.add(message);
  }
}

void main() {
  group('DfCrashlyticsErrorSink', () {
    late _FakeCrashlyticsCalls fake;
    late DfCrashlyticsErrorSink sink;

    setUp(() {
      fake = _FakeCrashlyticsCalls();
      sink = DfCrashlyticsErrorSink(calls: fake);
    });

    test('maps fatal, reason, exception, and stack trace correctly', () async {
      final error = StateError('boom');
      final stack = StackTrace.current;

      sink.recordError(error, stack, reason: 'background sync', fatal: true);
      sink.recordError('string error', null, fatal: false);

      expect(fake.errors.length, 2);

      final first = fake.errors[0];
      expect(first.exception, error);
      expect(first.stack, stack);
      expect(first.reason, 'background sync');
      expect(first.fatal, isTrue);

      final second = fake.errors[1];
      expect(second.exception, 'string error');
      expect(second.stack, isNull);
      expect(second.reason, isNull);
      expect(second.fatal, isFalse);
    });

    test(
      'maps setUser to setUserIdentifier and clears on null or empty',
      () async {
        sink.setUser('user-123');
        sink.setUser(null);
        sink.setUser('');

        expect(fake.userIdentifiers, ['user-123', '', '']);
      },
    );

    test(
      'maps log breadcrumbs and handles Crashlytics failures gracefully',
      () async {
        sink.log('Application launched');
        sink.log('Screen viewed: home');

        expect(fake.logs, ['Application launched', 'Screen viewed: home']);

        // Synchronous and asynchronous failures must not crash the caller.
        fake.shouldThrowSync = true;
        expect(
          () => sink.recordError(Exception('ignore'), null),
          returnsNormally,
        );
        expect(() => sink.setUser('user-x'), returnsNormally);
        expect(() => sink.log('log-x'), returnsNormally);

        fake.shouldThrowSync = false;
        fake.shouldThrowAsync = true;
        expect(
          () => sink.recordError(Exception('ignore-async'), null),
          returnsNormally,
        );
        expect(() => sink.setUser('user-async'), returnsNormally);
        expect(() => sink.log('log-async'), returnsNormally);

        await Future<void>.delayed(Duration.zero);
      },
    );
  });
}
