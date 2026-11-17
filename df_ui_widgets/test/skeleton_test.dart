import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfSkeleton and DfSkeletonList', () {
    testWidgets('renders skeletons and list, animates and disposes cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DfSkeleton(width: 100, height: 20),
                DfSkeleton.circle(size: 40),
                DfSkeleton.text(width: 80),
                Expanded(child: DfSkeletonList(itemCount: 3)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DfSkeleton), findsWidgets);
      expect(find.byType(DfSkeletonList), findsOneWidget);

      // Advance frames to ensure shimmer animation doesn't throw
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));

      // Unmount to ensure clean disposal
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      expect(find.byType(DfSkeleton), findsNothing);
      expect(find.byType(DfSkeletonList), findsNothing);
    });

    testWidgets('respects disableAnimations', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(body: DfSkeletonList(itemCount: 2)),
          ),
        ),
      );

      expect(find.byType(DfSkeletonList), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DfSkeletonList), findsOneWidget);
    });
  });
}
