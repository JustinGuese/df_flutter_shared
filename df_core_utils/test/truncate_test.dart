import 'package:flutter_test/flutter_test.dart';
import 'package:df_core_utils/df_core_utils.dart';

void main() {
  group('truncateAtWord', () {
    test('returns original string when shorter than or equal to maxChars', () {
      expect(truncateAtWord('hello', 10), 'hello');
      expect(truncateAtWord('hello', 5), 'hello');
      expect(truncateAtWord('', 5), '');
    });

    test('returns empty string for zero or negative maxChars', () {
      expect(truncateAtWord('hello', 0), '');
      expect(truncateAtWord('hello', -1), '');
    });

    test('cuts at word boundary when length exceeds maxChars', () {
      expect(truncateAtWord('hello world', 8), 'hello…');
      expect(truncateAtWord('hello beautiful world', 12), 'hello…');
    });

    test('cuts cleanly when cut lands exactly on a space', () {
      expect(truncateAtWord('hello world', 5), 'hello…');
      expect(truncateAtWord('hello world', 6), 'hello…');
    });

    test('long text cut at word boundary matches share_story test case', () {
      final text = List.filled(80, 'word').join(' ');
      final s = truncateAtWord(text, 200);
      expect(s.length, lessThanOrEqualTo(201));
      expect(s, endsWith('word…'));
    });

    test('cuts mid-word when no space exists before maxChars', () {
      expect(truncateAtWord('supercalifragilistic', 5), 'super…');
    });

    test('supports custom ellipsis', () {
      expect(truncateAtWord('hello world', 8, ellipsis: '...'), 'hello...');
    });

    test('handles whitespace characters like newline and tab', () {
      expect(truncateAtWord('hello\nworld', 8), 'hello…');
      expect(truncateAtWord('hello\tworld', 8), 'hello…');
    });
  });
}
