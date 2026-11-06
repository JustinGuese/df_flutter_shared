import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// Strings used by [DfTypingIndicator].
class DfTypingIndicatorStrings {
  const DfTypingIndicatorStrings({
    this.label = 'Thinking…',
  });

  /// The text displayed next to the pulsing dots.
  final String label;

  /// Alias for [label].
  String get thinking => label;
}

/// Bot-style bubble with pulsing dots, shown while waiting for an AI or chat response.
///
/// Generalised from the app chat typing indicator.
class DfTypingIndicator extends StatefulWidget {
  const DfTypingIndicator({
    super.key,
    this.label,
    this.strings = const DfTypingIndicatorStrings(),
    this.dotColor,
    this.backgroundColor,
    this.textStyle,
    this.alignment = Alignment.centerLeft,
    this.dotCount = 3,
    this.dotSize = 8.0,
    this.dotSpacing = 4.0,
    this.duration = const Duration(milliseconds: 1200),
    this.padding,
    this.margin,
    this.borderRadius,
  });

  /// Optional text label overriding [strings.label].
  /// Pass an empty string to show only the pulsing dots.
  final String? label;

  /// Localised strings for the indicator. Defaults to "Thinking…".
  final DfTypingIndicatorStrings strings;

  /// Custom dot tint. Defaults to `df.colors.brand.base`.
  final Color? dotColor;

  /// Bubble background color. Defaults to `df.colors.surfaceElevated.withValues(alpha: 0.6)`.
  final Color? backgroundColor;

  /// Text style for the label. Defaults to bodySmall in `df.colors.textSecondary`.
  final TextStyle? textStyle;

  /// Alignment within its parent. Defaults to [Alignment.centerLeft]. Set to null to skip [Align].
  final AlignmentGeometry? alignment;

  /// Number of pulsing dots. Defaults to 3.
  final int dotCount;

  /// Diameter of each dot in logical pixels. Defaults to 8.0.
  final double dotSize;

  /// Spacing between dots in logical pixels. Defaults to 4.0.
  final double dotSpacing;

  /// Duration of one full pulse cycle. Defaults to 1200ms.
  final Duration duration;

  /// Bubble internal padding.
  final EdgeInsetsGeometry? padding;

  /// Bubble external margin.
  final EdgeInsetsGeometry? margin;

  /// Bubble corner radius. Defaults to `df.shape.radiusLg`.
  final BorderRadius? borderRadius;

  @override
  State<DfTypingIndicator> createState() => _DfTypingIndicatorState();
}

class _DfTypingIndicatorState extends State<DfTypingIndicator>
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
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant DfTypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
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
    final theme = Theme.of(context);

    final effectiveLabel = widget.label ?? widget.strings.label;
    final effectiveBg = widget.backgroundColor ??
        df.colors.surfaceElevated.withValues(alpha: 0.6);
    final effectiveDotColor = widget.dotColor ?? df.colors.brand.base;
    final effectiveMargin = widget.margin ??
        EdgeInsets.symmetric(vertical: df.spacing.xs);
    final effectivePadding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: df.spacing.md,
          vertical: df.spacing.sm,
        );
    final effectiveRadius = widget.borderRadius ?? df.shape.radiusLg;

    final bubble = Container(
      margin: effectiveMargin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.dotCount; i++)
                  _dot(effectiveDotColor, i),
              ],
            ),
          ),
          if (effectiveLabel.isNotEmpty) ...[
            SizedBox(width: df.spacing.sm),
            Text(
              effectiveLabel,
              style: widget.textStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    color: df.colors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );

    if (widget.alignment != null) {
      return Align(
        alignment: widget.alignment!,
        child: bubble,
      );
    }
    return bubble;
  }

  Widget _dot(Color dotColor, int i) {
    final phase = ((_controller.value - i * 0.18) % 1.0 + 1.0) % 1.0;
    final pulse = (phase < 0.5 ? phase : 1 - phase) * 2; // 0..1..0
    final clampedPulse = pulse.clamp(0.0, 1.0);
    return Container(
      width: widget.dotSize,
      height: widget.dotSize,
      margin: EdgeInsets.symmetric(horizontal: widget.dotSpacing / 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor.withValues(
          alpha: (0.3 + 0.7 * clampedPulse).clamp(0.0, 1.0),
        ),
      ),
    );
  }
}
