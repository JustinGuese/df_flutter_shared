import 'dart:async';

import 'package:dio/dio.dart';

/// Provider callback for acquiring or refreshing an authentication token.
typedef DfTokenProvider = Future<String?> Function();

/// HTTP client wrapper for [Dio] with automatic Bearer token injection,
/// single-attempt 401 retry, and network issue detection.
class DfApiClient {
  DfApiClient({
    this.baseUrl = '',
    this.tokenProvider,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
    Map<String, dynamic>? defaultHeaders,
    Dio? dio,
  }) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            headers: {'Accept': 'application/json', ...?defaultHeaders},
          ),
        );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // If this request is already a retry, the authorization header was
          // already refreshed in onError.
          if (options.extra['_df_retried'] != true && tokenProvider != null) {
            try {
              final token = await tokenProvider!();
              if (token != null && token.isNotEmpty) {
                final headerValue = token.startsWith('Bearer ')
                    ? token
                    : 'Bearer $token';
                options.headers['Authorization'] = headerValue;
              }
            } catch (_) {
              // Best-effort: proceed even if tokenProvider throws
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final alreadyRetried =
                error.requestOptions.extra['_df_retried'] == true;

            if (!alreadyRetried) {
              error.requestOptions.extra['_df_retried'] = true;

              final errorDetail = _extractErrorDetail(error.response?.data);

              final isBackendNetworkIssue =
                  errorDetail.contains('Failed to resolve') ||
                  errorDetail.contains('NameResolutionError') ||
                  errorDetail.contains('HTTPSConnectionPool') ||
                  errorDetail.contains('Max retries exceeded') ||
                  errorDetail.contains('www.googleapis.com');

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

              if (tokenProvider != null) {
                try {
                  final newToken = await tokenProvider!();
                  if (newToken != null && newToken.isNotEmpty) {
                    final headerValue = newToken.startsWith('Bearer ')
                        ? newToken
                        : 'Bearer $newToken';
                    error.requestOptions.headers['Authorization'] = headerValue;
                  }
                  try {
                    // Temporarily allow 401 during retry so Dio does not re-enter
                    // the error queue and deadlock QueuedInterceptorsWrapper.
                    final retryOptions = Options(
                      method: error.requestOptions.method,
                      headers: error.requestOptions.headers,
                      responseType: error.requestOptions.responseType,
                      contentType: error.requestOptions.contentType,
                      extra: error.requestOptions.extra,
                      validateStatus: (_) => true,
                    );

                    final response = await _dio.request(
                      error.requestOptions.path,
                      data: error.requestOptions.data,
                      queryParameters: error.requestOptions.queryParameters,
                      cancelToken: error.requestOptions.cancelToken,
                      options: retryOptions,
                      onReceiveProgress: error.requestOptions.onReceiveProgress,
                      onSendProgress: error.requestOptions.onSendProgress,
                    );

                    if (response.statusCode != null &&
                        response.statusCode! >= 200 &&
                        response.statusCode! < 300) {
                      handler.resolve(response);
                      return;
                    }
                  } catch (_) {
                    // Retry failed; fall through to handler.next(error) below.
                  }
                } catch (_) {
                  // Token refresh failed; proceed to handler.next(error)
                }
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final String baseUrl;
  final DfTokenProvider? tokenProvider;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  late final Dio _dio;

  Dio get client => _dio;
  Dio get dio => _dio;

  static String _extractErrorDetail(dynamic data) {
    if (data == null) return '';
    if (data is Map) {
      return data['detail']?.toString() ??
          data['message']?.toString() ??
          data['code']?.toString() ??
          '';
    }
    return data.toString();
  }
}
