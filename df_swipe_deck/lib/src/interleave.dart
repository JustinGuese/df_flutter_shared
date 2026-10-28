/// Pure utility functions for deck item interleaving.
library;

/// Inserts a generated slot item after every [every] items from [items],
/// but never after the last item in the list.
///
/// [build] is called with an incrementing 0-based counter `n` for each
/// inserted item.
///
/// Throws an [ArgumentError] if [every] is less than or equal to 0.
List<T> interleaveEvery<T>(
  List<T> items, {
  required int every,
  required T Function(int n) build,
}) {
  if (every <= 0) {
    throw ArgumentError.value(every, 'every', 'Must be greater than zero');
  }
  if (items.isEmpty) return <T>[];

  final result = <T>[];
  var counter = 0;
  for (var i = 0; i < items.length; i++) {
    result.add(items[i]);
    final isLast = i == items.length - 1;
    if (!isLast && (i + 1) % every == 0) {
      result.add(build(counter++));
    }
  }
  return result;
}
