import 'package:df_ui_widgets/src/filter_chip_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfFilterChipBar', () {
    testWidgets('renders items and invokes onSelected callback', (tester) async {
      String? selectedItem;
      final items = ['All', 'Tech', 'Design', 'Business'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfFilterChipBar<String>(
              items: items,
              selected: 'All',
              onSelected: (item) => selectedItem = item,
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Tech'), findsOneWidget);
      expect(find.text('Design'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);

      await tester.tap(find.text('Tech'));
      await tester.pump();

      expect(selectedItem, 'Tech');
    });

    testWidgets('supports labelBuilder and trailing widget', (tester) async {
      int? selectedNumber;
      final items = [1, 2, 3];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfFilterChipBar<int>(
              items: items,
              selected: 1,
              labelBuilder: (n) => 'Item #$n',
              trailing: const Icon(Icons.tune),
              onSelected: (n) => selectedNumber = n,
            ),
          ),
        ),
      );

      expect(find.text('Item #1'), findsOneWidget);
      expect(find.text('Item #2'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);

      await tester.tap(find.text('Item #2'));
      await tester.pump();

      expect(selectedNumber, 2);
    });
  });
}
