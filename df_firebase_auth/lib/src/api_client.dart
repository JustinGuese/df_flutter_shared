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
            String? token;
            Exception? lastError;

            for (int attempt = 0; attempt < 5; attempt++) {
              try {
                final currentUser = _auth.currentUser;
                if (currentUser == null || currentUser.uid != user.uid) {
                  throw Exception('User authentication state changed');
                }

                final forceRefresh = attempt > 0;
                token = await currentUser.getIdToken(forceRefresh);

                if (token != null && token.isNotEmpty) {
                  break;
                }
              } catch (e) {
                lastError = e is Exception ? e : Exception(e.toString());
                if (attempt < 4) {
                  await Future.delayed(
                    Duration(milliseconds: 100 * (1 << attempt)),
                  );
                  continue;
                }
              }
            }

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              handler.next(options);
            } else {
              handler.reject(
                DioException(
                  requestOptions: options,
                  message:
                      'Failed to retrieve authentication token${lastError != null ? ': $lastError' : ''}. Please try again.',
                  type: DioExceptionType.unknown,
                ),
              );
              return;
            }
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
            if (error.response?.data != null) {
              if (error.response!.data is Map) {
                errorDetail = error.response!.data['detail']?.toString() ?? '';
              } else {
                errorDetail = error.response!.data.toString();
              }
            }

            final isMissingHeader =
                errorDetail.toLowerCase().contains('authorization header missing') ||
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
                final token = await user.getIdToken(true);
                if (token != null && token.isNotEmpty) {
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $token';
                  try {
                    final response = await _dio.fetch(error.requestOptions);
                    handler.resolve(response);
                    return;
                  } catch (retryError) {}
                }
              } catch (e) {}
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
