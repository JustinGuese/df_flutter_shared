import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// Provides a shared shimmer animation and palette for child [DfSkeleton] widgets.
class DfSkeletonScope extends InheritedWidget {
  const DfSkeletonScope({
    super.key,
    required this.animation,
    this.baseColor,
    this.highlightColor,
    required super.child,
  });

  /// The shared shimmer animation phase (0.0 to 1.0).
  final Animation<double> animation;

  /// Optional base placeholder color for descendant skeletons.
  final Color? baseColor;

  /// Optional highlight/shimmer sweep color for descendant skeletons.
  final Color? highlightColor;

  /// Look up the nearest enclosing [DfSkeletonScope].
  static DfSkeletonScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DfSkeletonScope>();
  }

  @override
  bool updateShouldNotify(DfSkeletonScope oldWidget) =>
      animation != oldWidget.animation ||
      baseColor != oldWidget.baseColor ||
      highlightColor != oldWidget.highlightColor;
}

/// A placeholder shimmer widget following DF design tokens and motion guidelines.
///
/// Automatically pauses motion when [MediaQuery.disableAnimationsOf] is true
/// or when `motion.ambient == Duration.zero`.
class DfSkeleton extends StatefulWidget {
  const DfSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.margin,
    this.child,
  });

  /// Circular skeleton, e.g. for avatars.
  const DfSkeleton.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.margin,
  }) : width = size,
       height = size,
       shape = BoxShape.circle,
       borderRadius = null,
       child = null;

  /// Text line skeleton.
  const DfSkeleton.text({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.margin,
  }) : shape = BoxShape.rectangle,
       child = null;

  /// Width in logical pixels. Defaults to match child or fill available space.
  final double? width;

  /// Height in logical pixels.
  final double? height;

  /// Corner radius for rectangular skeletons. Defaults to `context.df.shape.radiusMd`.
  final BorderRadius? borderRadius;

  /// Shape of the skeleton.
  final BoxShape shape;

  /// Background color of the placeholder. Defaults to surface/surfaceSunken tokens.
  final Color? baseColor;

  /// Color of the shimmering sweep. Defaults to surfaceElevated/hairline tokens.
  final Color? highlightColor;

  /// Shimmer duration. Defaults to `context.dfMotion.ambient`.
  final Duration? duration;

  /// Outer margin around the placeholder.
  final EdgeInsetsGeometry? margin;

  /// Optional child widget to shimmer via mask. If null, renders a decorated box.
  final Widget? child;

  @override
  State<DfSkeleton> createState() => _DfSkeletonState();
}

class _DfSkeletonState extends State<DfSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant DfSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  void _syncController() {
    final scope = DfSkeletonScope.maybeOf(context);
    if (scope != null) {
      _controller?.stop();
      _controller?.dispose();
      _controller = null;
      return;
    }

    final motion = context.dfMotion;
    final effectiveDuration = widget.duration ?? motion.ambient;

    if (effectiveDuration == Duration.zero ||
        MediaQuery.disableAnimationsOf(context)) {
      _controller?.stop();
    } else {
      _controller ??= AnimationController(
        vsync: this,
        duration: effectiveDuration,
      );
      if (_controller!.duration != effectiveDuration) {
        _controller!.duration = effectiveDuration;
      }
      if (!_controller!.isAnimating) {
        _controller!.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final scope = DfSkeletonScope.maybeOf(context);
    final isDark = df.colors.brightness == Brightness.dark;

    final effectiveBaseColor =
        widget.baseColor ??
        scope?.baseColor ??
        (isDark ? df.colors.surfaceElevated : df.colors.surfaceSunken);

    final effectiveHighlightColor =
        widget.highlightColor ??
        scope?.highlightColor ??
        (isDark ? df.colors.hairline : df.colors.surface);

    final animation = scope?.animation ?? _controller;
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context) ||
        context.dfMotion.ambient == Duration.zero ||
        animation == null;

    if (disableAnimations) {
      return _buildStatic(df, effectiveBaseColor);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final startX = -1.5 + (t * 3.0);
        final endX = startX + 1.2;

        final gradient = LinearGradient(
          begin: Alignment(startX, -0.3),
          end: Alignment(endX, 0.3),
          colors: [
            effectiveBaseColor,
            effectiveHighlightColor,
            effectiveBaseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        if (widget.child != null) {
          return Container(
            margin: widget.margin,
            child: ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => gradient.createShader(bounds),
              child: widget.child,
            ),
          );
        }

        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? (widget.borderRadius ?? df.shape.radiusMd)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildStatic(DfTokens df, Color baseColor) {
    if (widget.child != null) {
      return Container(margin: widget.margin, child: widget.child);
    }

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: baseColor,
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.rectangle
            ? (widget.borderRadius ?? df.shape.radiusMd)
            : null,
      ),
    );
  }
}

/// A shimmer skeleton list that renders repeating placeholder rows.
///
/// Synchronizes the shimmer wave across all list items using a shared
/// [DfSkeletonScope].
class DfSkeletonList extends StatefulWidget {
  const DfSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
    this.separator,
    this.padding,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  /// Number of skeleton items to show. Defaults to 5.
  final int itemCount;

  /// Custom builder for each skeleton row. If null, renders a standard avatar + 2-line placeholder.
  final NullableIndexedWidgetBuilder? itemBuilder;

  /// Separator between skeleton items. Defaults to a vertical spacer using `context.df.spacing.md`.
  final Widget? separator;

  /// Internal padding for the list. Defaults to `context.df.spacing.md` on all edges.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics. Defaults to [NeverScrollableScrollPhysics].
  final ScrollPhysics physics;

  /// Whether the list should shrink-wrap its contents. Defaults to true.
  final bool shrinkWrap;

  /// Optional base color for all items in this list.
  final Color? baseColor;

  /// Optional highlight color for all items in this list.
  final Color? highlightColor;

  /// Custom shimmer duration. Defaults to `context.dfMotion.ambient`.
  final Duration? duration;

  @override
  State<DfSkeletonList> createState() => _DfSkeletonListState();
}

class _DfSkeletonListState extends State<DfSkeletonList>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant DfSkeletonList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  void _syncController() {
    final parentScope = DfSkeletonScope.maybeOf(context);
    if (parentScope != null) {
      _controller?.stop();
      _controller?.dispose();
      _controller = null;
      return;
    }

    final motion = context.dfMotion;
    final effectiveDuration = widget.duration ?? motion.ambient;

    if (effectiveDuration == Duration.zero ||
        MediaQuery.disableAnimationsOf(context)) {
      _controller?.stop();
    } else {
      _controller ??= AnimationController(
        vsync: this,
        duration: effectiveDuration,
      );
      if (_controller!.duration != effectiveDuration) {
        _controller!.duration = effectiveDuration;
      }
      if (!_controller!.isAnimating) {
        _controller!.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final parentScope = DfSkeletonScope.maybeOf(context);
    final animation =
        parentScope?.animation ??
        _controller ??
        const AlwaysStoppedAnimation<double>(0.0);

    final effectivePadding = widget.padding ?? EdgeInsets.all(df.spacing.md);
    final effectiveSeparator =
        widget.separator ?? SizedBox(height: df.spacing.md);

    Widget buildItem(BuildContext ctx, int index) {
      if (widget.itemBuilder != null) {
        return widget.itemBuilder!(ctx, index) ?? const SizedBox.shrink();
      }
      return _defaultItem(ctx, df);
    }

    final list = ListView.separated(
      padding: effectivePadding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.itemCount,
      separatorBuilder: (_, _) => effectiveSeparator,
      itemBuilder: buildItem,
    );

    return DfSkeletonScope(
      animation: animation,
      baseColor: widget.baseColor ?? parentScope?.baseColor,
      highlightColor: widget.highlightColor ?? parentScope?.highlightColor,
      child: list,
    );
  }

  Widget _defaultItem(BuildContext context, DfTokens df) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: df.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const DfSkeleton.circle(size: 40),
          SizedBox(width: df.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DfSkeleton(
                  height: 14,
                  width: double.infinity,
                  borderRadius: df.shape.radiusSm,
                ),
                SizedBox(height: df.spacing.xs),
                DfSkeleton(
                  height: 12,
                  width: 140,
                  borderRadius: df.shape.radiusSm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
