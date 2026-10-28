import 'package:df_swipe_deck/df_swipe_deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('interleaveEvery', () {
    test('throws ArgumentError when every <= 0', () {
      expect(
        () => interleaveEvery(<int>[1, 2], every: 0, build: (n) => 99),
        throwsArgumentError,
      );
      expect(
        () => interleaveEvery(<int>[1, 2], every: -1, build: (n) => 99),
        throwsArgumentError,
      );
    });

    test('returns empty list for empty items', () {
      final result = interleaveEvery<String>(
        const [],
        every: 5,
        build: (n) => 'ad-$n',
      );
      expect(result, isEmpty);
    });

    test('N=5 on 4 items inserts nothing', () {
      final items = ['a', 'b', 'c', 'd'];
      final result = interleaveEvery(items, every: 5, build: (n) => 'ad-$n');
      expect(result, ['a', 'b', 'c', 'd']);
    });

    test('N=5 on 5 items inserts nothing (never last item)', () {
      final items = ['a', 'b', 'c', 'd', 'e'];
      final result = interleaveEvery(items, every: 5, build: (n) => 'ad-$n');
      expect(result, ['a', 'b', 'c', 'd', 'e']);
    });

    test('N=5 on 6 items inserts one item after 5th item', () {
      final items = ['a', 'b', 'c', 'd', 'e', 'f'];
      final result = interleaveEvery(items, every: 5, build: (n) => 'ad-$n');
      expect(result, ['a', 'b', 'c', 'd', 'e', 'ad-0', 'f']);
    });

    test('N=5 on 11 items inserts two items with incrementing n counter', () {
      final items = List.generate(11, (i) => 'item-$i');
      final builtIndices = <int>[];
      final result = interleaveEvery(
        items,
        every: 5,
        build: (n) {
          builtIndices.add(n);
          return 'ad-$n';
        },
      );

      expect(builtIndices, [0, 1]);
      expect(result, [
        'item-0',
        'item-1',
        'item-2',
        'item-3',
        'item-4',
        'ad-0',
        'item-5',
        'item-6',
        'item-7',
        'item-8',
        'item-9',
        'ad-1',
        'item-10',
      ]);
      expect(result.last, 'item-10');
    });
  });
}
