# df_swipe_deck

Generic swipe deck harness wrapping `flutter_card_swiper` with action bar, first-run hint, progress bar, and slot interleaving. Pure UI and deck coordination — app-agnostic, token-driven, English-default copy.

Used by [DataFortress.cloud](https://datafortress.cloud/) apps.

---

## Installation

```yaml
dependencies:
  df_swipe_deck:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_swipe_deck
      ref: main
```

```dart
import 'package:df_swipe_deck/df_swipe_deck.dart';
```

---

## Quick start

```dart
final controller = DfSwipeDeckController();

Column(
  children: [
    DfDeckProgressBar(current: currentCount, total: feed.length),
    Expanded(
      child: DfSwipeDeck<MyItem>(
        controller: controller,
        items: feed,
        deckKey: ValueKey(feedCategory),
        onLike: (item) => handleLike(item),
        onPass: (item) => handlePass(item),
        onOpen: (item) => openItemDetail(item),
        onUndo: (item) => handleUndo(item),
        canOpen: (item) => !item.isAd,
        cardBuilder: (context, item, isFront) => MyCard(item: item, isFront: isFront),
        onIndexChanged: (index) => print('Top card: $index'),
        onEnd: () => print('End of deck reached'),
      ),
    ),
    const DfSwipeHint(),
    DfSwipeActionBar(controller: controller),
  ],
)
```

---

## Components

- **`DfSwipeDeck<T>`**: Wraps `flutter_card_swiper` with type-safe callbacks (`onLike`, `onPass`, `onOpen`, `onUndo`), up-swipe to open without advancing the card, restart key (`deckKey`), and haptic feedback.
- **`DfSwipeDeckController`**: Programmatically trigger `like()`, `pass()`, `open()`, `undo()`, and `restart()`.
- **`DfSwipeActionBar`**: Action bar with undo, pass, open, and like buttons styled using DF design tokens.
- **`DfSwipeHint`**: Animated first-run nudging arrows that respect `MediaQuery.disableAnimationsOf`.
- **`DfDeckProgressBar`**: Progress bar showing current card progress against the total.
- **`interleaveEvery<T>`**: Pure utility function inserting ad or sponsor slots after every N items without placing one at the end.
- **`DfSwipeStrings`**: Overridable copy for tooltips, hints, and progress readouts with English defaults and `{placeholder}` support.
