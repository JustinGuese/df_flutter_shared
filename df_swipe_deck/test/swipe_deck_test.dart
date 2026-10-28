import 'package:df_swipe_deck/df_swipe_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHarness({
    required List<String> items,
    DfSwipeDeckController? controller,
    Key? deckKey,
    void Function(String)? onLike,
    void Function(String)? onPass,
    void Function(String)? onOpen,
    void Function(String)? onUndo,
    VoidCallback? onEnd,
    bool Function(String)? canOpen,
    ValueChanged<int>? onIndexChanged,
    WidgetBuilder? emptyBuilder,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 600,
            child: DfSwipeDeck<String>(
              items: items,
              controller: controller,
              deckKey: deckKey,
              onLike: onLike,
              onPass: onPass,
              onOpen: onOpen,
              onUndo: onUndo,
              onEnd: onEnd,
              canOpen: canOpen,
              onIndexChanged: onIndexChanged,
              emptyBuilder: emptyBuilder,
              cardBuilder: (context, item, isFront) => Container(
                key: ValueKey('card_$item'),
                color: Colors.blue,
                child: Center(child: Text('Card: $item, front: $isFront')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('DfSwipeDeck', () {
    testWidgets(
      'like, pass, open, undo callbacks fire with right item and open does not advance',
      (tester) async {
        final controller = DfSwipeDeckController();
        final likedItems = <String>[];
        final passedItems = <String>[];
        final openedItems = <String>[];
        final undoneItems = <String>[];
        final indexHistory = <int>[];

        await tester.pumpWidget(
          buildHarness(
            items: ['card-1', 'card-2', 'card-3'],
            controller: controller,
            onLike: likedItems.add,
            onPass: passedItems.add,
            onOpen: openedItems.add,
            onUndo: undoneItems.add,
            onIndexChanged: indexHistory.add,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Card: card-1, front: true'), findsOneWidget);
        expect(controller.topIndex, 0);

        // 1. Open on card-1: does NOT advance the deck
        controller.open();
        await tester.pumpAndSettle();

        expect(openedItems, ['card-1']);
        expect(controller.topIndex, 0);
        expect(find.text('Card: card-1, front: true'), findsOneWidget);

        // 2. Like on card-1: advances to card-2
        controller.like();
        await tester.pumpAndSettle();

        expect(likedItems, ['card-1']);
        expect(controller.topIndex, 1);
        expect(find.text('Card: card-2, front: true'), findsOneWidget);

        // 3. Open on card-2: fires onOpen with card-2 and does NOT advance
        controller.open();
        await tester.pumpAndSettle();

        expect(openedItems, ['card-1', 'card-2']);
        expect(controller.topIndex, 1);
        expect(find.text('Card: card-2, front: true'), findsOneWidget);

        // 4. Pass on card-2: advances to card-3
        controller.pass();
        await tester.pumpAndSettle();

        expect(passedItems, ['card-2']);
        expect(controller.topIndex, 2);
        expect(find.text('Card: card-3, front: true'), findsOneWidget);

        // 5. Undo restores card-2
        controller.undo();
        await tester.pumpAndSettle();

        expect(undoneItems, ['card-2']);
        expect(controller.topIndex, 1);
        expect(find.text('Card: card-2, front: true'), findsOneWidget);

        // Check index tracking
        expect(indexHistory, containsAllInOrder([1, 2, 1]));
      },
    );

    testWidgets('up-swipe gesture fires onOpen and keeps the card on top', (
      tester,
    ) async {
      final opened = <String>[];
      await tester.pumpWidget(
        buildHarness(items: ['first', 'second'], onOpen: opened.add),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card: first, front: true'), findsOneWidget);

      // Drag card up
      await tester.drag(
        find.byKey(const ValueKey('card_first')),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();

      expect(opened, ['first']);
      // Card remains first
      expect(find.text('Card: first, front: true'), findsOneWidget);
    });

    testWidgets('canOpen false suppresses onOpen for gestures and controller', (
      tester,
    ) async {
      final controller = DfSwipeDeckController();
      final opened = <String>[];

      await tester.pumpWidget(
        buildHarness(
          items: ['ad_card', 'content_card'],
          controller: controller,
          canOpen: (item) => !item.startsWith('ad_'),
          onOpen: opened.add,
        ),
      );
      await tester.pumpAndSettle();

      // Controller open suppressed
      controller.open();
      await tester.pumpAndSettle();
      expect(opened, isEmpty);

      // Gesture up-swipe suppressed
      await tester.drag(
        find.byKey(const ValueKey('card_ad_card')),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      expect(find.text('Card: ad_card, front: true'), findsOneWidget);

      // Pass the ad card
      controller.pass();
      await tester.pumpAndSettle();
      expect(find.text('Card: content_card, front: true'), findsOneWidget);

      // Now open works for content_card
      controller.open();
      await tester.pumpAndSettle();
      expect(opened, ['content_card']);
    });

    testWidgets('deckKey change restarts deck from card 0', (tester) async {
      final controller = DfSwipeDeckController();
      var keyIndex = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => keyIndex++),
                      child: const Text('Restart'),
                    ),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 400,
                          height: 600,
                          child: DfSwipeDeck<String>(
                            items: const ['item-0', 'item-1', 'item-2'],
                            controller: controller,
                            deckKey: ValueKey('key_$keyIndex'),
                            cardBuilder: (context, item, isFront) => Container(
                              color: Colors.blue,
                              child: Center(
                                child: Text('Card: $item, front: $isFront'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card: item-0, front: true'), findsOneWidget);

      // Advance
      controller.like();
      await tester.pumpAndSettle();
      expect(find.text('Card: item-1, front: true'), findsOneWidget);
      expect(controller.topIndex, 1);

      // Restart via deckKey
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      expect(controller.topIndex, 0);
      expect(find.text('Card: item-0, front: true'), findsOneWidget);
    });

    testWidgets('controller.restart resets to card 0', (tester) async {
      final controller = DfSwipeDeckController();
      await tester.pumpWidget(
        buildHarness(
          items: ['item-0', 'item-1', 'item-2'],
          controller: controller,
        ),
      );
      await tester.pumpAndSettle();

      controller.like();
      await tester.pumpAndSettle();
      expect(controller.topIndex, 1);

      controller.restart();
      await tester.pumpAndSettle();

      expect(controller.topIndex, 0);
      expect(find.text('Card: item-0, front: true'), findsOneWidget);
    });

    testWidgets('onEnd callback fires when last card is swiped', (
      tester,
    ) async {
      final controller = DfSwipeDeckController();
      var ended = false;

      await tester.pumpWidget(
        buildHarness(
          items: ['solo'],
          controller: controller,
          onEnd: () => ended = true,
        ),
      );
      await tester.pumpAndSettle();

      controller.like();
      await tester.pumpAndSettle();

      expect(ended, isTrue);
    });

    testWidgets('empty items list renders emptyBuilder', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          items: [],
          emptyBuilder: (_) => const Text('Deck is empty'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deck is empty'), findsOneWidget);
    });
  });
}
