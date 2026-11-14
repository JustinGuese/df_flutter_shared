import 'dart:typed_data';

import 'package:df_api/df_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DfApiClient', () {
    test('injects Bearer token into request headers', () async {
      RequestOptions? recordedOptions;
      final dio = Dio();
      dio.httpClientAdapter = _MockAdapter((options) async {
        recordedOptions = options;
        return ResponseBody.fromString(
          '{"ok": true}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = DfApiClient(
        baseUrl: 'https://api.example.com',
        tokenProvider: () async => 'initial-token',
        dio: dio,
      );

      final response = await client.client.get('/profile');
      expect(response.statusCode, 200);
      expect(recordedOptions?.headers['Authorization'], 'Bearer initial-token');
    });

    test('401 triggers exactly one token refresh and retry', () async {
      int tokenCalls = 0;
      final tokens = ['token-v1', 'token-v2', 'token-v3'];
      Future<String?> tokenProvider() async {
        final token = tokens[tokenCalls];
        tokenCalls++;
        return token;
      }

      int requestCount = 0;
      final capturedHeaders = <String?>[];

      final dio = Dio();
      dio.httpClientAdapter = _MockAdapter((options) async {
        requestCount++;
        capturedHeaders.add(options.headers['Authorization'] as String?);
        if (requestCount == 1) {
          return ResponseBody.fromString(
            '{"detail": "token expired"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{"status": "success"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = DfApiClient(
        baseUrl: 'https://api.example.com',
        tokenProvider: tokenProvider,
        dio: dio,
      );

      final response = await client.client.get('/protected');
      expect(response.statusCode, 200);
      expect(requestCount, 2);
      expect(tokenCalls, 2);
      expect(capturedHeaders, ['Bearer token-v1', 'Bearer token-v2']);
    });

    test('repeated 401 on retry does not loop infinitely', () async {
      int tokenCalls = 0;
      Future<String?> tokenProvider() async {
        tokenCalls++;
        return 'token-$tokenCalls';
      }

      int requestCount = 0;
      final dio = Dio();
      dio.httpClientAdapter = _MockAdapter((options) async {
        requestCount++;
        return ResponseBody.fromString(
          '{"detail": "unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = DfApiClient(
        baseUrl: 'https://api.example.com',
        tokenProvider: tokenProvider,
        dio: dio,
      );

      Object? caught;
      try {
        await client.client.get('/always-401');
      } catch (e) {
        caught = e;
      }

      expect(caught, isA<DioException>());
      expect(requestCount, 2);
      expect(tokenCalls, 2);
    });
  });

  group('mapDioError', () {
    test('extracts status code and detail message from response Map', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/user'),
        response: Response(
          requestOptions: RequestOptions(path: '/user'),
          statusCode: 404,
          data: {'detail': 'User not found', 'code': 'NOT_FOUND'},
        ),
      );

      final mapped = mapDioError(dioError);
      expect(mapped.status, 404);
      expect(mapped.message, 'User not found');
      expect(mapped.code, 'NOT_FOUND');
    });

    test('handles non-Dio error gracefully', () {
      final mapped = mapDioError(Exception('database down'));
      expect(mapped.status, isNull);
      expect(mapped.message, contains('database down'));
    });
  });
}
