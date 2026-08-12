import 'package:flutter/widgets.dart';

/// Animation durations and curves.
///
/// Supersedes `AnimationDurations` in df_core_utils, which was the repo's only
/// design token and lived in the wrong package.
///
/// Motion in DF apps is restrained: state changes are quick, entrances are
/// staggered but short, and only one element per screen is allowed a signature
/// movement. Always gate decorative motion on
/// `MediaQuery.disableAnimationsOf(context)`.
@immutable
class DfMotion {
  const DfMotion({
    this.fast = const Duration(milliseconds: 150),
    this.normal = const Duration(milliseconds: 250),
    this.medium = const Duration(milliseconds: 400),
    this.slow = const Duration(milliseconds: 600),
    this.pulse = const Duration(milliseconds: 1000),
    this.ambient = const Duration(milliseconds: 2000),
    this.stagger = const Duration(milliseconds: 40),
    this.standard = Curves.easeOutCubic,
    this.emphasis = Curves.easeOutBack,
    this.exit = Curves.easeInCubic,
  });

  /// Everything is instant. For `MediaQuery.disableAnimationsOf(context)`.
  const DfMotion.none()
    : fast = Duration.zero,
      normal = Duration.zero,
      medium = Duration.zero,
      slow = Duration.zero,
      pulse = Duration.zero,
      ambient = Duration.zero,
      stagger = Duration.zero,
      standard = Curves.linear,
      emphasis = Curves.linear,
      exit = Curves.linear;

  /// Hover, press, ripple.
  final Duration fast;

  /// The default: toggles, expands, colour changes.
  final Duration normal;

  /// Page and sheet transitions.
  final Duration medium;

  /// Deliberate, attention-carrying moves.
  final Duration slow;

  /// One beat of a repeating attention pulse.
  final Duration pulse;

  /// Background/ambient loops.
  final Duration ambient;

  /// Delay between items in a staggered list entrance.
  final Duration stagger;

  final Curve standard;

  /// Slight overshoot. Reserve for the one signature element per screen.
  final Curve emphasis;

  final Curve exit;

  /// The stagger delay for item [index], capped so long lists do not end up
  /// with a visible wait before the last row appears.
  Duration staggerFor(int index, {int cap = 12}) =>
      stagger * (index > cap ? cap : index);

  /// Resolves to [DfMotion.none] when the platform asks for reduced motion.
  ///
  /// Prefer this over reading durations directly, so accessibility is handled
  /// in one place rather than at every call site.
  DfMotion resolve(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? const DfMotion.none() : this;

  DfMotion copyWith({
    Duration? fast,
    Duration? normal,
    Duration? medium,
    Duration? slow,
    Duration? pulse,
    Duration? ambient,
    Duration? stagger,
    Curve? standard,
    Curve? emphasis,
    Curve? exit,
  }) => DfMotion(
    fast: fast ?? this.fast,
    normal: normal ?? this.normal,
    medium: medium ?? this.medium,
    slow: slow ?? this.slow,
    pulse: pulse ?? this.pulse,
    ambient: ambient ?? this.ambient,
    stagger: stagger ?? this.stagger,
    standard: standard ?? this.standard,
    emphasis: emphasis ?? this.emphasis,
    exit: exit ?? this.exit,
  );

  static DfMotion lerp(DfMotion a, DfMotion b, double t) => t < 0.5 ? a : b;
}
