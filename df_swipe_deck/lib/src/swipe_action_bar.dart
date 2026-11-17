import 'package:df_theme/df_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'swipe_deck.dart';
import 'swipe_strings.dart';

/// Action bar beneath [DfSwipeDeck] with round buttons for undo, pass, open, and like.
///
/// Actions can be driven either by passing callbacks directly or by providing
/// a [controller].
class DfSwipeActionBar extends StatelessWidget {
  const DfSwipeActionBar({
    super.key,
    this.onUndo,
    this.onPass,
    this.onOpen,
    this.onRead,
    this.onLike,
    this.controller,
    this.strings = const DfSwipeStrings(),
    this.enableHaptics = true,
  });

  final VoidCallback? onUndo;
  final VoidCallback? onPass;
  final VoidCallback? onOpen;
  final VoidCallback? onRead;
  final VoidCallback? onLike;
  final DfSwipeDeckController? controller;
  final DfSwipeStrings strings;
  final bool enableHaptics;

  VoidCallback? get _undoAction => onUndo ?? controller?.undo;
  VoidCallback? get _passAction => onPass ?? controller?.pass;
  VoidCallback? get _openAction => onOpen ?? onRead ?? controller?.open;
  VoidCallback? get _likeAction => onLike ?? controller?.like;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final undo = _undoAction;
    final pass = _passAction;
    final open = _openAction;
    final like = _likeAction;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: df.spacing.xl,
        vertical: df.spacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (undo != null)
            _RoundAction(
              icon: Icons.undo_rounded,
              color: df.colors.textSecondary,
              size: 40,
              tooltip: strings.undoTooltip,
              enableHaptics: enableHaptics,
              onPressed: undo,
            ),
          if (pass != null)
            _RoundAction(
              icon: Icons.close_rounded,
              color: df.colors.error.base,
              size: 56,
              tooltip: strings.passTooltip,
              enableHaptics: enableHaptics,
              onPressed: pass,
            ),
          if (open != null)
            _RoundAction(
              icon: Icons.arrow_upward_rounded,
              color: df.colors.brand.deep,
              size: 48,
              tooltip: strings.openTooltip,
              enableHaptics: enableHaptics,
              onPressed: open,
            ),
          if (like != null)
            _RoundAction(
              icon: Icons.favorite_rounded,
              color: df.colors.success.base,
              size: 56,
              tooltip: strings.likeTooltip,
              enableHaptics: enableHaptics,
              onPressed: like,
            ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.size,
    required this.tooltip,
    required this.enableHaptics,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final double size;
  final String tooltip;
  final bool enableHaptics;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: df.colors.surface,
        shape: CircleBorder(
          side: BorderSide(color: color.withValues(alpha: 0.35), width: 1.5),
        ),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (enableHaptics) {
              HapticFeedback.selectionClick();
            }
            onPressed();
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: color, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}
