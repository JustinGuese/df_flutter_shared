import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'swipe_strings.dart';

/// Non-blocking first-run coach: nudging arrows under the card instead of a modal.
///
/// Automatically stops animation when reduced motion is requested
/// via [MediaQuery.disableAnimationsOf].
class DfSwipeHint extends StatefulWidget {
  const DfSwipeHint({
    super.key,
    this.strings = const DfSwipeStrings(),
    this.duration = const Duration(milliseconds: 1400),
  });

  /// Strings used for pass and like labels.
  final DfSwipeStrings strings;

  /// Duration of one back-and-forth bounce animation.
  final Duration duration;

  @override
  State<DfSwipeHint> createState() => _DfSwipeHintState();
}

class _DfSwipeHintState extends State<DfSwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final style = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: df.colors.textSecondary);
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final dx = animationsDisabled
            ? 0.0
            : (Curves.easeInOut.transform(_controller.value) - 0.5) * 12;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(-dx, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: df.colors.error.base,
                  ),
                  SizedBox(width: df.spacing.xs),
                  Text(widget.strings.passHint, style: style),
                ],
              ),
            ),
            SizedBox(width: df.spacing.xl),
            Transform.translate(
              offset: Offset(dx, 0),
              child: Row(
                children: [
                  Text(widget.strings.likeHint, style: style),
                  SizedBox(width: df.spacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: df.colors.success.base,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
