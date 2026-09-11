import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:df_firebase_auth/src/auth_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RecordingAnalyticsSink analytics;

  setUp(() => analytics = RecordingAnalyticsSink.install());
  tearDown(DfAnalyticsCore.debugReset);

  group('trackAuth', () {
    test('an email sign-up is sign_up', () async {
      await trackAuth(DfAuthMethod.email, DfAuthFlow.signUp, () async => 1);

      expect(analytics.names, [DfEvents.signUp]);
      expect(analytics.events.single.parameters, {'method': 'email'});
    });

    test('an SSO sign-in is login unless the account is new', () async {
      await trackAuth(
        DfAuthMethod.google,
        DfAuthFlow.sso,
        () async => false,
        isNewUser: (isNew) => isNew,
      );
      await trackAuth(
        DfAuthMethod.apple,
        DfAuthFlow.sso,
        () async => true,
        isNewUser: (isNew) => isNew,
      );

      expect(analytics.names, [DfEvents.login, DfEvents.signUp]);
      expect(analytics.events.last.parameters, {'method': 'apple'});
    });

    test('a failure is reported with its code and rethrown', () async {
      final future = trackAuth<void>(
        DfAuthMethod.email,
        DfAuthFlow.login,
        () async => throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'someone@example.com got it wrong',
        ),
      );

      await expectLater(future, throwsA(isA<FirebaseAuthException>()));
      expect(analytics.names, [DfEvents.authFailed]);
      expect(analytics.events.single.parameters, {
        'method': 'email',
        'flow': 'login',
        'error_code': 'wrong-password',
      });
    });

    test('backing out of the sheet is a cancel, not a failure', () async {
      final future = trackAuth<void>(
        DfAuthMethod.apple,
        DfAuthFlow.sso,
        () async => throw Exception('Apple Sign-In was cancelled'),
      );

      await expectLater(future, throwsException);
      expect(analytics.names, [DfEvents.authCancelled]);
    });
  });

  group('classifyAuthError', () {
    test('keeps Firebase codes and buckets wrapped errors', () {
      expect(
        classifyAuthError(FirebaseAuthException(code: 'user-not-found')),
        'user-not-found',
      );
      expect(
        classifyAuthError(Exception('Google sign in was cancelled or failed')),
        'cancelled',
      );
      expect(
        classifyAuthError(
          Exception(
            'An account already exists with a different sign-in method',
          ),
        ),
        'account_exists',
      );
      expect(
        classifyAuthError(Exception('requires the People API to be enabled')),
        'people_api',
      );
      expect(classifyAuthError(StateError('boom')), 'unknown');
    });
  });
}
