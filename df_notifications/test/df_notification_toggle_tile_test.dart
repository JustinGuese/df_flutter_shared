import 'package:df_notifications/src/df_notification_strings.dart';
import 'package:df_notifications/src/df_notification_toggle_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildSubject({
  String prefKey = DfNotificationToggleTile.defaultNotificationPrefKey,
  Future<bool> Function()? requestPermission,
  Future<void> Function()? onEnabled,
  Future<void> Function()? onDisabled,
  DfNotificationStrings strings = const DfNotificationStrings(),
}) {
  return MaterialApp(
    home: Scaffold(
      body: DfNotificationToggleTile(
        prefKey: prefKey,
        requestPermission: requestPermission,
        onEnabled: onEnabled,
        onDisabled: onDisabled,
        strings: strings,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DfNotificationToggleTile', () {
    testWidgets('shows spinner while loading pref, then switch reflecting initial state',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        DfNotificationToggleTile.defaultNotificationPrefKey: true,
      });

      await tester.pumpWidget(_buildSubject());

      // While loading the preference, a spinner is visible.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Switch), findsNothing);

      await tester.pumpAndSettle();

      // Once loaded, the switch is visible and turned on.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Switch), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('granted -> persisted true + onEnabled + enabled snackbar',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'test_pref': false,
      });

      var onEnabledCalled = false;
      var requestPermissionCalled = false;

      await tester.pumpWidget(
        _buildSubject(
          prefKey: 'test_pref',
          requestPermission: () async {
            requestPermissionCalled = true;
            return true;
          },
          onEnabled: () async {
            onEnabledCalled = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      // Tap the switch to enable.
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(requestPermissionCalled, isTrue);
      expect(onEnabledCalled, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('test_pref'), isTrue);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Notifications enabled.'), findsOneWidget);
    });

    testWidgets('denied -> stays off + permission denied snackbar',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'test_pref': false,
      });

      var onEnabledCalled = false;

      await tester.pumpWidget(
        _buildSubject(
          prefKey: 'test_pref',
          requestPermission: () async => false,
          onEnabled: () async {
            onEnabledCalled = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      // Tap to attempt enable.
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(onEnabledCalled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('test_pref') ?? false, isFalse);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(
        find.text('Notification permission was not granted.'),
        findsOneWidget,
      );
    });

    testWidgets('disable path -> persisted false + onDisabled + disabled snackbar',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'test_pref': true,
      });

      var onDisabledCalled = false;

      await tester.pumpWidget(
        _buildSubject(
          prefKey: 'test_pref',
          onDisabled: () async {
            onDisabledCalled = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      // Tap to disable.
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(onDisabledCalled, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('test_pref'), isFalse);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.text('Notifications disabled.'), findsOneWidget);
    });
  });
}
