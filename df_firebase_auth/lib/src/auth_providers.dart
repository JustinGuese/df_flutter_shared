import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_client.dart';
import 'auth_config.dart';
import 'auth_repository.dart';

/// Must be overridden in the app with a concrete [AuthConfig].
final authConfigProvider = Provider<AuthConfig>((ref) {
  throw UnsupportedError(
    'authConfigProvider must be overridden in ProviderScope.overrides',
  );
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  final config = ref.watch(authConfigProvider);
  final signIn = GoogleSignIn.instance;

  if (!kIsWeb && config.serverClientId != null) {
    signIn.initialize(serverClientId: config.serverClientId);
  } else {
    signIn.initialize();
  }

  return signIn;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref
      .watch(authStateChangesProvider)
      .maybeWhen(data: (user) => user, orElse: () => null);
});

final apiClientProvider = Provider<Dio>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final config = ref.watch(authConfigProvider);
  return ApiClient(auth, authRepository, config).client;
});
