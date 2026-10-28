import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

/// Builder callback for cards in [DfSwipeDeck].
typedef DfSwipeCardBuilder<T> =
    Widget Function(BuildContext context, T item, bool isFront);

/// Callback invoked on swipe actions with the item being swiped.
typedef DfSwipeItemCallback<T> = void Function(T item);

/// External controller to programmatically trigger swipe actions or undo.
class DfSwipeDeckController {
  _DfSwipeDeckState? _state;

  /// Whether this controller is currently bound to a [DfSwipeDeck].
  bool get isAttached => _state != null;

  /// The current top card index, or 0 if not attached.
  int get topIndex => _state?.topIndex ?? 0;

  /// Swipe right (like).
  void like() => _state?.like();

  /// Swipe left (pass).
  void pass() => _state?.pass();

  /// Trigger open on the current top card without swiping it away.
  void open() => _state?.open();

  /// Undo the last swipe.
  void undo() => _state?.undo();

  /// Restart the deck from card 0.
  void restart() => _state?.restart();

  void _attach(_DfSwipeDeckState state) => _state = state;
  void _detach() => _state = null;
  void dispose() => _state = null;
}

/// Generic swipe deck harness wrapping [CardSwiper].
class DfSwipeDeck<T> extends StatefulWidget {
  const DfSwipeDeck({
    super.key,
    required this.items,
    required this.cardBuilder,
    this.onLike,
    this.onPass,
    this.onOpen,
    this.onUndo,
    this.onEnd,
    this.canOpen,
    this.controller,
    this.deckKey,
    this.onIndexChanged,
    this.enableHaptics = true,
    this.numberOfCardsDisplayed = 2,
    this.isLoop = false,
    this.allowedSwipeDirection = const AllowedSwipeDirection.only(
      up: true,
      down: false,
      left: true,
      right: true,
    ),
    this.padding,
    this.emptyBuilder,
  });

  final List<T> items;
  final DfSwipeCardBuilder<T> cardBuilder;
  final DfSwipeItemCallback<T>? onLike;
  final DfSwipeItemCallback<T>? onPass;
  final DfSwipeItemCallback<T>? onOpen;
  final DfSwipeItemCallback<T>? onUndo;
  final VoidCallback? onEnd;
  final bool Function(T item)? canOpen;
  final DfSwipeDeckController? controller;
  final Key? deckKey;
  final ValueChanged<int>? onIndexChanged;
  final bool enableHaptics;
  final int numberOfCardsDisplayed;
  final bool isLoop;
  final AllowedSwipeDirection allowedSwipeDirection;
  final EdgeInsetsGeometry? padding;
  final WidgetBuilder? emptyBuilder;

  @override
  State<DfSwipeDeck<T>> createState() => _DfSwipeDeckState<T>();
}

class _DfSwipeDeckState<T> extends State<DfSwipeDeck<T>> {
  late final CardSwiperController _swiperController = CardSwiperController();
  int _topIndex = 0;
  int _deckEpoch = 0;

  int get topIndex => _topIndex;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant DfSwipeDeck<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
    if (oldWidget.deckKey != widget.deckKey) {
      restart();
    } else if (widget.items.isNotEmpty && _topIndex >= widget.items.length) {
      _topIndex = widget.items.length - 1;
      widget.onIndexChanged?.call(_topIndex);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _swiperController.dispose();
    super.dispose();
  }

  void like() => _swiperController.swipe(CardSwiperDirection.right);
  void pass() => _swiperController.swipe(CardSwiperDirection.left);
  void undo() => _swiperController.undo();

  void open() {
    if (widget.items.isEmpty) return;
    if (_topIndex < 0 || _topIndex >= widget.items.length) return;
    final item = widget.items[_topIndex];
    if (widget.canOpen?.call(item) ?? true) {
      if (widget.enableHaptics) HapticFeedback.selectionClick();
      widget.onOpen?.call(item);
    }
  }

  void restart() {
    setState(() {
      _topIndex = 0;
      _deckEpoch++;
    });
    widget.onIndexChanged?.call(0);
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex < 0 || previousIndex >= widget.items.length) return false;
    final item = widget.items[previousIndex];

    if (direction == CardSwiperDirection.top) {
      final can = widget.canOpen?.call(item) ?? true;
      if (can) {
        if (widget.enableHaptics) HapticFeedback.selectionClick();
        widget.onOpen?.call(item);
      }
      return false;
    }

    if (direction == CardSwiperDirection.right ||
        direction == CardSwiperDirection.left) {
      if (widget.enableHaptics) HapticFeedback.lightImpact();
      final newIndex = currentIndex ?? (previousIndex + 1);
      setState(() => _topIndex = newIndex);
      widget.onIndexChanged?.call(newIndex);
      if (direction == CardSwiperDirection.right) {
        widget.onLike?.call(item);
      } else {
        widget.onPass?.call(item);
      }
      return true;
    }

    return false;
  }

  bool _onUndo(int? previous, int currentIndex, CardSwiperDirection dir) {
    if (currentIndex < 0 || currentIndex >= widget.items.length) return false;
    if (widget.enableHaptics) HapticFeedback.lightImpact();
    setState(() => _topIndex = currentIndex);
    widget.onIndexChanged?.call(currentIndex);
    widget.onUndo?.call(widget.items[currentIndex]);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    final df = context.df;
    final resolvedPadding =
        widget.padding ??
        EdgeInsets.symmetric(
          horizontal: df.spacing.mdPlus,
          vertical: df.spacing.lg,
        );

    return CardSwiper(
      key: ValueKey('df_card_swiper_${widget.deckKey}_$_deckEpoch'),
      controller: _swiperController,
      cardsCount: widget.items.length,
      numberOfCardsDisplayed: widget.items.length.clamp(
        1,
        widget.numberOfCardsDisplayed,
      ),
      isLoop: widget.isLoop,
      padding: resolvedPadding,
      allowedSwipeDirection: widget.allowedSwipeDirection,
      onEnd: widget.onEnd,
      onUndo: _onUndo,
      onSwipe: _onSwipe,
      cardBuilder: (context, index, percentX, percentY) {
        if (index < 0 || index >= widget.items.length) {
          return const SizedBox.shrink();
        }
        return widget.cardBuilder(
          context,
          widget.items[index],
          index == _topIndex,
        );
      },
    );
  }
}
