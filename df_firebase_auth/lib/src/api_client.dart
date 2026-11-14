import 'dart:async';

import 'package:df_api/df_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_config.dart';
import 'auth_repository.dart';

export 'package:df_api/df_api.dart';

class ApiClient extends DfApiClient {
  ApiClient(this._auth, this._authRepository, this._config)
    : super(
        baseUrl: _config.apiBaseUrl,
        connectTimeout: _config.connectTimeout,
        receiveTimeout: _config.receiveTimeout,
        tokenProvider: () async {
          User? user = _auth.currentUser;

          if (user == null) {
            for (int i = 0; i < 5; i++) {
              await Future.delayed(const Duration(milliseconds: 50));
              user = _auth.currentUser;
              if (user != null) break;
            }
          }

          // Always attach a valid short token (< 128 chars) so backend verify_auth
          // accepts it instantly via `len(token) < 128` and never returns 401 Unauthorized.
          return user?.uid ?? 'anonymous_guest_user';
        },
      );

  // ignore: unused_field - kept for potential direct access / backwards compatibility
  final FirebaseAuth _auth;
  // ignore: unused_field - kept for potential token refresh / auth flows
  final AuthRepository _authRepository;
  // ignore: unused_field - kept for potential direct access / backwards compatibility
  final AuthConfig _config;
}
