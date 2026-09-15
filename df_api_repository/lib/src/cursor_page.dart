/// A page from a cursor-paginated endpoint: `{"items": [...], "next_cursor":
/// "..."|null}`. This is distinct from [BaseApiRepository.getList]'s bare-array
/// `skip`/`limit` shape — some backends paginate by opaque cursor instead.
class DfCursorPage<T> {
  const DfCursorPage({required this.items, this.nextCursor});

  factory DfCursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return DfCursorPage<T>(
      items: rawItems.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  final List<T> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}

/// Accumulates pages from a cursor-paginated endpoint into one growing list.
/// Construct one per list view (it is not a Riverpod provider itself — wrap it
/// in a Notifier if you want it to drive a widget rebuild).
class DfCursorPager<T> {
  DfCursorPager({
    required Future<DfCursorPage<T>> Function(String? cursor) fetchPage,
  }) : _fetchPage = fetchPage;

  final Future<DfCursorPage<T>> Function(String? cursor) _fetchPage;

  final List<T> items = [];
  String? _nextCursor;
  bool _startedOnce = false;

  bool get hasMore => !_startedOnce || _nextCursor != null;

  /// Fetches and appends the next page. No-op once [hasMore] is false.
  Future<void> loadMore() async {
    if (!hasMore) return;
    final page = await _fetchPage(_nextCursor);
    items.addAll(page.items);
    _nextCursor = page.nextCursor;
    _startedOnce = true;
  }

  /// Clears accumulated items and cursor state, so the next [loadMore] starts
  /// from the first page again.
  void reset() {
    items.clear();
    _nextCursor = null;
    _startedOnce = false;
  }
}
