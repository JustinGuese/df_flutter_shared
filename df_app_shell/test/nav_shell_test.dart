import 'package:df_app_shell/df_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DfNavShell switches rail vs bar at the breakpoint', (tester) async {
    int selected = 0;

    Widget buildShell() {
      return MaterialApp(
        home: DfNavShell(
          currentIndex: selected,
          onDestinationSelected: (idx) => selected = idx,
          destinations: const [
            DfNavDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            DfNavDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
              badge: Text('1'),
            ),
          ],
          body: const Text('Body Content'),
        ),
      );
    }

    // Narrow layout (< 600 breakpoint): should use bottom NavigationBar
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildShell());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Body Content'), findsOneWidget);

    // Tap destination in NavigationBar
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(selected, 1);

    // Wide layout (>= 600 breakpoint): should use NavigationRail
    tester.view.physicalSize = const Size(800, 800);
    await tester.pumpWidget(buildShell());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Body Content'), findsOneWidget);

    // Tap destination in NavigationRail
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(selected, 0);
  });
}
