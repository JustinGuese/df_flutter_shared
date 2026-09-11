import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:df_tour/df_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RecordingAnalyticsSink analytics;

  setUp(() => analytics = RecordingAnalyticsSink.install());
  tearDown(DfAnalyticsCore.debugReset);

  testWidgets('reports each spotlight and a skip, tagged with the step id', (
    tester,
  ) async {
    final key = GlobalKey();
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(key: key, width: 40)),
        ),
      ),
    );

    showTourCoachMarks(
      tester.element(find.byType(Scaffold)),
      targets: [TourTarget(key: key, title: 'Write', body: 'x')],
      analyticsId: 'write',
      onFinish: () => finished = true,
    );
    await tester.pump(Duration.zero);
    await tester.pump(const Duration(milliseconds: 700));

    expect(analytics.named(DfEvents.tourStepView).single.parameters, {
      DfEventParams.stepId: 'write',
      DfEventParams.stepIndex: 1,
    });

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(finished, isTrue);
    expect(analytics.named(DfEvents.tourComplete).single.parameters, {
      DfEventParams.stepId: 'write',
      DfEventParams.skipped: 1,
      DfEventParams.stepsSeen: 1,
    });
  });
}
