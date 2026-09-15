import 'package:dio/dio.dart';

import 'api_repository_config.dart';
import 'cursor_page.dart';

/// Base for Dio-based repositories. Provides [dio] and optional [config].
/// Use [getList] for paginated GET list endpoints.
abstract class BaseApiRepository {
  BaseApiRepository(this.dio, {ApiRepositoryConfig? config})
    : config = config ?? const ApiRepositoryConfig();

  final Dio dio;
  final ApiRepositoryConfig config;

  /// GET a list from [path], with optional [skip] and [limit] (default from config).
  /// [queryParameters] are merged with skip/limit. [fromJson] maps each item.
  Future<List<T>> getList<T>(
    String path, {
    int skip = 0,
    int? limit,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final params = Map<String, dynamic>.from(
      queryParameters ?? <String, dynamic>{},
    );
    params['skip'] = skip;
    params['limit'] = limit ?? config.defaultPageSize;

    final response = await dio.get<List<dynamic>>(
      path,
      queryParameters: params,
    );
    final data = response.data ?? [];
    return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  /// GET a single JSON object from [path].
  Future<T> getOne<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(path);
    return fromJson(response.data!);
  }

  /// GET one page from a cursor-paginated endpoint: `{items, next_cursor}`.
  /// Pass the previous page's `nextCursor` to fetch the next one, or null for
  /// the first page. [queryParameters] are merged with cursor/limit.
  Future<DfCursorPage<T>> getCursorPage<T>(
    String path, {
    String? cursor,
    int? limit,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final params = Map<String, dynamic>.from(
      queryParameters ?? <String, dynamic>{},
    );
    if (cursor != null) params['cursor'] = cursor;
    params['limit'] = limit ?? config.defaultPageSize;

    final response = await dio.get<Map<String, dynamic>>(
      path,
      queryParameters: params,
    );
    return DfCursorPage.fromJson(response.data ?? const {}, fromJson);
  }
}
