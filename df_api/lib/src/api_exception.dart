import 'package:dio/dio.dart';

/// Exception thrown or mapped from API client errors.
class DfApiException implements Exception {
  const DfApiException({
    this.status,
    required this.message,
    this.code,
    this.details,
  });

  /// HTTP status code, if available.
  final int? status;

  /// Human-readable error message.
  final String message;

  /// Optional machine-readable error code (e.g. from RFC 9457 problem+json).
  final String? code;

  /// Optional raw response or error details.
  final Object? details;

  @override
  String toString() {
    if (status != null) {
      return 'DfApiException($status): $message';
    }
    return 'DfApiException: $message';
  }
}

/// Maps any caught error or [DioException] to a [DfApiException].
DfApiException mapDioError(Object e) {
  if (e is DfApiException) {
    return e;
  }

  if (e is DioException) {
    final status = e.response?.statusCode;
    String? message;
    String? code;
    Object? details;

    final data = e.response?.data;
    if (data != null) {
      details = data;
      if (data is Map) {
        final detail = data['detail'];
        final msg = data['message'];
        final err = data['error'];
        final c = data['code'];

        if (c != null) {
          code = c.toString();
        }

        if (detail is String && detail.trim().isNotEmpty) {
          message = detail.trim();
        } else if (msg is String && msg.trim().isNotEmpty) {
          message = msg.trim();
        } else if (err is String && err.trim().isNotEmpty) {
          message = err.trim();
        } else if (detail != null) {
          message = detail.toString();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        message = data.trim();
      }
    }

    message ??= e.message;
    if (message == null || message.trim().isEmpty) {
      message = switch (e.type) {
        DioExceptionType.connectionTimeout => 'Connection timed out',
        DioExceptionType.sendTimeout => 'Send timed out',
        DioExceptionType.receiveTimeout => 'Receive timed out',
        DioExceptionType.badCertificate => 'Bad certificate',
        DioExceptionType.badResponse => 'Bad response (${status ?? "unknown"})',
        DioExceptionType.cancel => 'Request cancelled',
        DioExceptionType.connectionError => 'Connection error',
        _ => 'Network error',
      };
    }

    return DfApiException(
      status: status,
      message: message,
      code: code,
      details: details,
    );
  }

  return DfApiException(status: null, message: e.toString());
}
