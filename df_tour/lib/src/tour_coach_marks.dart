import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_theme/df_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'tour_bubble.dart';
import 'tour_strings.dart';
import 'tour_target.dart';

/// Builds the [TargetFocus] list for [targets], skipping any target whose
/// [GlobalKey] isn't currently attached to a render object.
///
/// This filter matters: `tutorial_coach_mark` throws when asked to focus a
/// key with no render object, which happens constantly in real screens —
/// conditionally-rendered cards, content still loading, a tab that isn't the
/// active one. Without this filter, showing a tour on a screen that hasn't
/// finished laying out crashes instead of just showing fewer targets.
///
/// [radius] is a corner radius in logical pixels; callers should pass a value
/// from `context.df.shape` (`showTourCoachMarks` does this for you) rather
/// than a literal, so the spotlight shape matches the app's design tokens.
List<TargetFocus> buildTourTargetFocus(
  List<TourTarget> targets, {
  required double radius,
  DfTourStrings strings = const DfTourStrings(),
}) {
  final mounted = targets.where((t) => t.key.currentContext != null).toList();

  return [
    for (var i = 0; i < mounted.length; i++)
      TargetFocus(
        identify: 'df_tour_$i',
        keyTarget: mounted[i].key,
        shape: mounted[i].circle
            ? ShapeLightFocus.Circle
            : ShapeLightFocus.RRect,
        radius: radius,
        paddingFocus: 6,
        contents: [
          TargetContent(
            align: mounted[i].align,
            builder: (context, controller) => TourBubble(
              target: mounted[i],
              index: i,
              total: mounted.length,
              strings: strings,
            ),
          ),
        ],
      ),
  ];
}

/// Shows the coach-mark overlay for [targets] on [context].
///
/// Call this from `addPostFrameCallback`, not directly from `initState` or
/// `build` — before the first frame, target `GlobalKey`s have no render
/// object yet and every target would be filtered out by
/// [buildTourTargetFocus]. Returns `false` when nothing was mounted (so the
/// caller knows not to mark the step as shown, and can retry next frame
/// instead of silently skipping it); returns `true` once the overlay is
/// showing.
///
/// Reports `tour_step_view` for each spotlight shown and one `tour_complete`
/// (with `skipped`) when the overlay closes, tagged with [analyticsId] — pass
/// the step's id so reports can tell the steps of a multi-step tour apart.
bool showTourCoachMarks(
  BuildContext context, {
  required List<TourTarget> targets,
  DfTourStrings strings = const DfTourStrings(),
  VoidCallback? onFinish,
  String analyticsId = 'tour',
}) {
  final df = context.df;
  final focusTargets = buildTourTargetFocus(
    targets,
    radius: df.shape.md,
    strings: strings,
  );
  if (focusTargets.isEmpty) return false;

  var stepsSeen = 0;
  var reportedEnd = false;
  void reportEnd({required bool skipped}) {
    if (reportedEnd) return;
    reportedEnd = true;
    DfAnalyticsCore.track(DfEvents.tourComplete, {
      DfEventParams.stepId: analyticsId,
      DfEventParams.skipped: skipped,
      DfEventParams.stepsSeen: stepsSeen,
    });
  }

  TutorialCoachMark(
    targets: focusTargets,
    // The brand's deep weight rather than plain black: a coach-mark scrim is
    // still a surface, and the house rule is that dark fills stay tinted to
    // the brand rather than reading as flat black.
    colorShadow: df.colors.brand.deep,
    opacityShadow: 0.88,
    textSkip: strings.skipLabel,
    textStyleSkip: TextStyle(
      color: df.colors.textOnBrand,
      fontWeight: FontWeight.w600,
    ),
    alignSkip: Alignment.topRight,
    hideSkip: false,
    beforeFocus: (_) {
      stepsSeen++;
      DfAnalyticsCore.track(DfEvents.tourStepView, {
        DfEventParams.stepId: analyticsId,
        DfEventParams.stepIndex: stepsSeen,
      });
    },
    onFinish: () {
      reportEnd(skipped: false);
      onFinish?.call();
    },
    onSkip: () {
      reportEnd(skipped: true);
      onFinish?.call();
      return true;
    },
  ).show(context: context);

  return true;
}
