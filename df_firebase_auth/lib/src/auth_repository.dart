import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  AuthRepository(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    debugPrint(
      '[AuthRepository] Email/password sign-in successful. '
      'uid=${user?.uid}, email=${user?.email}',
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    debugPrint(
      '[AuthRepository] Email/password sign-up successful. '
      'uid=${user?.uid}, email=${user?.email}',
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      final completer = Completer<GoogleSignInAccount?>();
      StreamSubscription? subscription;

      try {
        subscription = _googleSignIn.authenticationEvents.listen(
          (event) {
            try {
              final eventDynamic = event as dynamic;
              GoogleSignInAccount? account;

              if (eventDynamic is GoogleSignInAccount) {
                account = eventDynamic;
              } else if (eventDynamic.user != null) {
                account = eventDynamic.user as GoogleSignInAccount?;
              } else if (eventDynamic.account != null) {
                account = eventDynamic.account as GoogleSignInAccount?;
              }

              if (account != null && !completer.isCompleted) {
                completer.complete(account);
              }
            } catch (e) {
              // Continue listening
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
        );

        if (_googleSignIn.supportsAuthenticate()) {
          await _googleSignIn.authenticate();
        } else {
          await _googleSignIn.attemptLightweightAuthentication();
        }

        googleUser = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () => null,
        );
      } finally {
        await subscription?.cancel();
      }

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled or failed');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          'Google Sign-In did not return an idToken. '
          'Please check your OAuth client configuration.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
          'An account already exists with a different sign-in method',
        );
      }
      if (e.code == 'invalid-credential' &&
          e.message?.contains('idToken') == true) {
        throw Exception(
          'Google Sign-In requires idToken for Firebase. '
          'This may require backend token exchange. Please check your implementation.',
        );
      }
      rethrow;
    } on Exception catch (e) {
      if (e.toString().contains('cancelled') ||
          e.toString().contains('canceled')) {
        rethrow;
      }
      if (e.toString().contains('People API') ||
          e.toString().contains('people.googleapis.com') ||
          e.toString().contains('403') ||
          e.toString().contains('PERMISSION_DENIED')) {
        throw Exception(
          'Google Sign-In requires the People API to be enabled. '
          'Please enable it in your Google Cloud project.',
        );
      }
      rethrow;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    debugPrint('🍎 [Apple Sign-In] Starting Apple Sign-In flow...');
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256Hash(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);

      final user = _auth.currentUser;
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty) &&
          appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
        await user.updateDisplayName(displayName);
        await user.reload();
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('Apple Sign-In was cancelled');
        case AuthorizationErrorCode.failed:
          throw Exception('Apple Sign-In failed: ${e.message}');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Invalid response from Apple Sign-In');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Apple Sign-In not handled');
        case AuthorizationErrorCode.unknown:
          throw Exception('Unknown error during Apple Sign-In');
        default:
          throw Exception('Apple Sign-In error: ${e.message}');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
          'An account already exists with a different sign-in method',
        );
      }
      if (e.code == 'invalid-credential') {
        throw Exception(
          'Apple Sign-In credential is invalid. Please try again.',
        );
      }
      rethrow;
    } on Exception catch (e) {
      if (e.toString().contains('cancelled') ||
          e.toString().contains('canceled')) {
        rethrow;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await user.delete();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'For security reasons, please sign in again before deleting your account.',
        );
      }
      rethrow;
    }
  }
}
