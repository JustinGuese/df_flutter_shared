import 'package:df_tour/df_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildTourTargetFocus unmounted-key filtering', () {
    testWidgets('drops targets whose key has no render object', (tester) async {
      final mountedKey = GlobalKey();
      final unmountedKey = GlobalKey(); // never attached to any widget

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Container(key: mountedKey)),
        ),
      );

      final targets = [
        TourTarget(key: mountedKey, title: 'Mounted', body: 'Is on screen'),
        TourTarget(key: unmountedKey, title: 'Unmounted', body: 'Never built'),
      ];

      final focus = buildTourTargetFocus(targets, radius: 12);

      // Without the filter, tutorial_coach_mark throws trying to resolve the
      // unmounted key's render object — so only the mounted target may appear.
      expect(focus, hasLength(1));
      expect(focus.single.keyTarget, mountedKey);
    });

    testWidgets('returns an empty list when nothing is mounted', (
      tester,
    ) async {
      final targets = [
        TourTarget(key: GlobalKey(), title: 'A', body: 'a'),
        TourTarget(key: GlobalKey(), title: 'B', body: 'b'),
      ];

      final focus = buildTourTargetFocus(targets, radius: 12);
      expect(focus, isEmpty);
    });

    testWidgets('preserves order and count among mounted targets', (
      tester,
    ) async {
      final keyA = GlobalKey();
      final keyB = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: keyA),
                Container(key: keyB),
              ],
            ),
          ),
        ),
      );

      final targets = [
        TourTarget(key: keyA, title: 'A', body: 'a'),
        TourTarget(key: keyB, title: 'B', body: 'b'),
      ];

      final focus = buildTourTargetFocus(targets, radius: 12);
      expect(focus, hasLength(2));
      expect(focus[0].keyTarget, keyA);
      expect(focus[1].keyTarget, keyB);
    });

    testWidgets(
      'shows the tour only for mounted targets via showTourCoachMarks',
      (tester) async {
        final mountedKey = GlobalKey();
        final unmountedKey = GlobalKey();
        var finished = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Container(key: mountedKey)),
          ),
        );

        final context = tester.element(find.byType(Scaffold));
        final shown = showTourCoachMarks(
          context,
          targets: [
            TourTarget(key: mountedKey, title: 'Mounted', body: 'x'),
            TourTarget(key: unmountedKey, title: 'Unmounted', body: 'y'),
          ],
          onFinish: () => finished = true,
        );

        // At least one target was mounted, so the overlay is shown rather than
        // silently doing nothing — the unmounted target is just skipped, and
        // this call must not throw the way an unfiltered list would.
        expect(shown, isTrue);
        expect(finished, isFalse);
        // showTourCoachMarks schedules the overlay insertion via
        // Future.delayed(Duration.zero, ...) internally — flush it so the test
        // doesn't leave a pending timer behind.
        await tester.pump(Duration.zero);
        await tester.pump(const Duration(milliseconds: 700));
      },
    );

    testWidgets('showTourCoachMarks returns false when nothing is mounted', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final context = tester.element(find.byType(Scaffold));

      final shown = showTourCoachMarks(
        context,
        targets: [TourTarget(key: GlobalKey(), title: 'Ghost', body: 'x')],
      );

      expect(shown, isFalse);
    });
  });
}
