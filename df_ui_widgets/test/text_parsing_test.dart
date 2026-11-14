import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dfParseKeywords trims and drops empties', () {
    expect(dfParseKeywords(' a, ,b ,,c'), ['a', 'b', 'c']);
  });

  test('dfParseSummaryPoints strips bullets and numbering', () {
    expect(dfParseSummaryPoints('• one\n- two\n3. three\n\n'), [
      'one',
      'two',
      'three',
    ]);
    expect(dfParseSummaryPoints(null), isEmpty);
  });
}
