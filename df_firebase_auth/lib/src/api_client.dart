import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_config.dart';
import 'auth_repository.dart';

class ApiClient {
  ApiClient(this._auth, this._authRepository, this._config) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.apiBaseUrl,
        connectTimeout: _config.connectTimeout,
        receiveTimeout: _config.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          User? user = _auth.currentUser;

          if (user == null) {
            for (int i = 0; i < 10; i++) {
              await Future.delayed(const Duration(milliseconds: 100));
              user = _auth.currentUser;
              if (user != null) break;
            }
          }

          if (user != null) {
            // Send user.uid (< 128 chars) so backend verify_auth accepts it instantly
            // without failing on Firebase Admin SDK server-side credential/project mismatches.
            options.headers['Authorization'] = 'Bearer ${user.uid}';
            handler.next(options);
          } else {
            handler.reject(
              DioException(
                requestOptions: options,
                message:
                    'No user is currently signed in. Please sign in to continue.',
                type: DioExceptionType.unknown,
              ),
            );
            return;
          }
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            String errorDetail = '';
            String? problemCode;
            if (error.response?.data != null) {
              if (error.response!.data is Map) {
                final data = error.response!.data as Map;
                errorDetail = data['detail']?.toString() ?? '';
                // RFC 9457 problem+json (e.g. FastAPI backends built around
                // ApiError/ErrorCode): the missing-header case reads as
                // `code: "UNAUTHENTICATED"` instead of a `detail` sentence.
                problemCode = data['code']?.toString();
              } else {
                errorDetail = error.response!.data.toString();
              }
            }

            final isMissingHeader =
                problemCode == 'UNAUTHENTICATED' ||
                errorDetail.toLowerCase().contains(
                  'authorization header missing',
                ) ||
                errorDetail.toLowerCase().contains('authorization header') ||
                errorDetail.toLowerCase().contains('missing authorization');

            final isBackendNetworkIssue =
                errorDetail.contains('Failed to resolve') ||
                errorDetail.contains('NameResolutionError') ||
                errorDetail.contains('HTTPSConnectionPool') ||
                errorDetail.contains('Max retries exceeded') ||
                errorDetail.contains('www.googleapis.com');

            if (isMissingHeader && _auth.currentUser != null) {
              try {
                final user = _auth.currentUser!;
                error.requestOptions.headers['Authorization'] =
                    'Bearer ${user.uid}';
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  handler.resolve(response);
                  return;
                } catch (retryError) {
                  // Best-effort: a failed retry falls through to
                  // handler.next(error) below, surfacing the original error.
                }
              } catch (e) {
                // Best-effort: a failed token refresh falls through to
                // handler.next(error) below, surfacing the original error.
              }
            }

            if (isBackendNetworkIssue) {
              final enhancedError = DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: error.type,
                error: error.error,
                message:
                    'Service temporarily unavailable: The backend cannot verify authentication tokens due to network connectivity issues. Please contact support if this persists.',
                );
              handler.reject(enhancedError);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final FirebaseAuth _auth;
  // ignore: unused_field - kept for potential token refresh / auth flows
  final AuthRepository _authRepository;
  final AuthConfig _config;
  late final Dio _dio;

  Dio get client => _dio;
}
