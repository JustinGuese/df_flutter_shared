import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// Wraps a scrollable and overlays a "there's more below" affordance: a soft
/// gradient fade at the bottom edge plus a gently bouncing chevron. Both
/// auto-hide once the user reaches the end, and never appear when the content
/// already fits.
///
/// House convention: any scroll area whose content can overflow
/// (questionnaires, onboarding, tab bodies) wraps in this, and the screen's
/// primary action belongs in a pinned bottom footer rather than inline in the
/// scroll body. Without the cue, people tap "next" before scrolling and miss
/// whatever sat below the fold.
///
/// No [ScrollController] threading is needed — position comes from bubbling
/// scroll notifications, so [child] can keep or omit its own controller.
///
/// ```dart
/// Column(
///   children: [
///     Expanded(
///       child: ScrollHint(
///         child: ListView(children: [...]),
///       ),
///     ),
///     const _PinnedFooter(),
///   ],
/// )
/// ```
class ScrollHint extends StatefulWidget {
  const ScrollHint({
    super.key,
    required this.child,
    this.backgroundColor,
    this.chevronColor,
    this.bottomInset = 0,
    this.threshold = 24,
  });

  /// The scrollable to wrap.
  final Widget child;

  /// The surface the fade blends into. Defaults to the theme canvas; pass the
  /// actual colour behind the scrollable when it differs (a card, or the bottom
  /// stop of a gradient), otherwise the fade ends on the wrong tone.
  final Color? backgroundColor;

  /// Chevron tint. Defaults to the theme accent.
  final Color? chevronColor;

  /// Inset from the bottom edge. Raise it to clear a pinned footer sitting over
  /// the same stack.
  final double bottomInset;

  /// Show the cue while more than this many pixels remain below the fold.
  final double threshold;

  @override
  State<ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _hasMore = false;

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  /// Recompute visibility from the latest scroll metrics.
  void _update(ScrollMetrics metrics) {
    final hasMore =
        metrics.hasContentDimensions && metrics.extentAfter > widget.threshold;
    if (hasMore != _hasMore) {
      setState(() => _hasMore = hasMore);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    // Reduced motion keeps the fade — that is the part carrying the
    // information — and only drops the bounce.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _bounce.stop();
    } else if (_hasMore && !_bounce.isAnimating) {
      _bounce.repeat(reverse: true);
    } else if (!_hasMore && _bounce.isAnimating) {
      _bounce.stop();
    }

    final background = widget.backgroundColor ?? df.colors.canvas;
    final chevronColor = widget.chevronColor ?? df.colors.accent.base;

    return NotificationListener<ScrollMetricsNotification>(
      // Fires on layout changes, including before any user scroll, so the cue
      // is correct on first paint and switches off when content shrinks to fit.
      onNotification: (n) {
        _update(n.metrics);
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _update(n.metrics);
          return false;
        },
        child: Stack(
          children: [
            widget.child,
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.bottomInset,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hasMore ? 1 : 0,
                  duration: df.motion.normal,
                  child: SizedBox(
                    height: 64,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                background.withValues(alpha: 0),
                                background,
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: df.spacing.xxs + 2),
                          child: AnimatedBuilder(
                            animation: _bounce,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(
                                0,
                                reduceMotion ? 0 : -4 * _bounce.value,
                              ),
                              child: child,
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: chevronColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
