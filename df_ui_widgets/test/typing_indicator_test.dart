import 'package:df_ui_widgets/src/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfTypingIndicator', () {
    testWidgets('renders, animates without throwing, and disposes cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DfTypingIndicator(),
          ),
        ),
      );

      expect(find.byType(DfTypingIndicator), findsOneWidget);
      expect(find.text('Thinking…'), findsOneWidget);

      // Advance frames to verify animation runs without throwing
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 600));

      // Unmount to verify clean disposal
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(DfTypingIndicator), findsNothing);
    });

    testWidgets('supports custom label and respects disabled animations', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: DfTypingIndicator(
                label: 'Generating summary…',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Generating summary…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Generating summary…'), findsOneWidget);
    });
  });
}
