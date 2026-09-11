import 'dart:async';

import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// How the user authenticated — the `method` parameter of `login`/`sign_up`.
enum DfAuthMethod { email, google, apple }

/// The `flow` parameter: what the attempt was for. `sso` is a Google/Apple
/// sign-in, where only the result tells a new account from a returning one.
abstract final class DfAuthFlow {
  static const login = 'login';
  static const signUp = 'sign_up';
  static const sso = 'sso';
}

/// Sends the signed-in account id to analytics whenever it changes — including
/// a session restored on launch, which no sign-in call ever sees, and sign-out.
///
/// Call once after `Firebase.initializeApp`. Whether the id actually leaves the
/// device is the installed sink's decision (`sendUserId` in df_analytics).
StreamSubscription<User?> dfBindAnalyticsIdentity(FirebaseAuth auth) =>
    auth.authStateChanges().listen((user) {
      DfAnalyticsCore.identify(user?.uid);
    });

/// Runs [op] and reports its outcome: `sign_up` or `login` on success,
/// `auth_cancelled` when the user backed out, `auth_failed` otherwise. Errors
/// are rethrown untouched — reporting never changes what the caller sees.
///
/// A [DfAuthFlow.signUp] success is always `sign_up`; any other flow is
/// `sign_up` only when [isNewUser] says the account was just created.
Future<T> trackAuth<T>(
  DfAuthMethod method,
  String flow,
  Future<T> Function() op, {
  bool Function(T result)? isNewUser,
}) async {
  final T result;
  try {
    result = await op();
  } catch (error) {
    final code = classifyAuthError(error);
    if (code == 'cancelled') {
      DfAnalyticsCore.track(DfEvents.authCancelled, {
        DfEventParams.method: method.name,
      });
    } else {
      DfAnalyticsCore.track(DfEvents.authFailed, {
        DfEventParams.method: method.name,
        DfEventParams.flow: flow,
        DfEventParams.errorCode: code,
      });
    }
    rethrow;
  }

  final created =
      flow == DfAuthFlow.signUp || (isNewUser?.call(result) ?? false);
  DfAnalyticsCore.track(created ? DfEvents.signUp : DfEvents.login, {
    DfEventParams.method: method.name,
  });
  return result;
}

/// A reportable code for an auth error. Firebase errors keep their own code
/// (`wrong-password`, `email-already-in-use`); the repository's wrapped errors
/// are bucketed by what they say. The message itself is never reported — it
/// can contain the user's email address.
String classifyAuthError(Object error) {
  if (error is FirebaseAuthException) return error.code;
  final text = error.toString();
  if (text.contains('cancelled') || text.contains('canceled')) {
    return 'cancelled';
  }
  if (text.contains('different sign-in method')) return 'account_exists';
  if (text.contains('People API')) return 'people_api';
  if (text.contains('idToken')) return 'no_id_token';
  if (text.contains('credential is invalid')) return 'invalid_credential';
  return 'unknown';
}
