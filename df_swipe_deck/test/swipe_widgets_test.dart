import 'package:df_swipe_deck/df_swipe_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfSwipeStrings', () {
    test('default strings and placeholder substitution', () {
      const strings = DfSwipeStrings();
      expect(strings.undoTooltip, 'Undo last swipe');
      expect(strings.passTooltip, 'Pass');
      expect(strings.openTooltip, 'Read full story');
      expect(strings.likeTooltip, 'Like');
      expect(strings.passHint, 'Pass');
      expect(strings.likeHint, 'Like & save');

      expect(strings.fillProgress(current: 3, total: 10), '3 / 10');
      expect(
        DfSwipeStrings.fill('Hello {name}!', {'name': 'Alice'}),
        'Hello Alice!',
      );
    });
  });

  group('DfDeckProgressBar', () {
    testWidgets('renders progress bar and formatted count text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DfDeckProgressBar(current: 4, total: 10)),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('4 / 10'), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.4);
    });

    testWidgets('supports read named parameter alias and clamps value', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DfDeckProgressBar(read: 15, total: 10)),
        ),
      );

      expect(find.text('10 / 10'), findsOneWidget);
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 1.0);
    });

    testWidgets('handles zero total safely', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DfDeckProgressBar(current: 0, total: 0)),
        ),
      );

      expect(find.text('0 / 0'), findsOneWidget);
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.0);
    });
  });

  group('DfSwipeHint', () {
    testWidgets('renders pass and like hint labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DfSwipeHint())),
      );

      expect(find.text('Pass'), findsOneWidget);
      expect(find.text('Like & save'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('stops animation when animations are disabled', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(home: Scaffold(body: DfSwipeHint())),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Pass'), findsOneWidget);
    });
  });

  group('DfSwipeActionBar', () {
    testWidgets('renders all four action buttons and fires callbacks', (
      tester,
    ) async {
      var undoFired = false;
      var passFired = false;
      var openFired = false;
      var likeFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfSwipeActionBar(
              onUndo: () => undoFired = true,
              onPass: () => passFired = true,
              onOpen: () => openFired = true,
              onLike: () => likeFired = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.undo_rounded));
      expect(undoFired, isTrue);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(passFired, isTrue);

      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      expect(openFired, isTrue);

      await tester.tap(find.byIcon(Icons.favorite_rounded));
      expect(likeFired, isTrue);
    });

    testWidgets('works with DfSwipeDeckController and onRead alias', (
      tester,
    ) async {
      final controller = DfSwipeDeckController();
      var readFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DfSwipeActionBar(
              controller: controller,
              onRead: () => readFired = true,
            ),
          ),
        ),
      );

      // onRead overrides controller.open
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      expect(readFired, isTrue);
    });
  });
}
