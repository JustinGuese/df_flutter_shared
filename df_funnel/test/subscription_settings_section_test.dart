import 'package:df_funnel/src/subscription_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('DfSubscriptionSettingsSection', () {
    testWidgets('shows success snackbar on restore purchases success', (tester) async {
      const strings = DfSubscriptionSettingsStrings();

      await tester.pumpWidget(
        _buildTestWidget(
          DfSubscriptionSettingsSection(
            isWeb: false,
            onRestorePurchases: () async => true,
          ),
        ),
      );

      await tester.tap(find.text(strings.restorePurchasesTitle));
      await tester.pumpAndSettle();

      expect(find.text(strings.restoreSuccessMessage), findsOneWidget);
    });

    testWidgets('shows error snackbar on restore purchases error', (tester) async {
      const strings = DfSubscriptionSettingsStrings();

      await tester.pumpWidget(
        _buildTestWidget(
          DfSubscriptionSettingsSection(
            isWeb: false,
            onRestorePurchases: () async => throw Exception('Network timeout'),
          ),
        ),
      );

      await tester.tap(find.text(strings.restorePurchasesTitle));
      await tester.pumpAndSettle();

      expect(
        find.text(strings.restoreError(Exception('Network timeout'))),
        findsOneWidget,
      );
    });

    testWidgets('shows web fallback message when running on web', (tester) async {
      const strings = DfSubscriptionSettingsStrings();
      var restoreCalled = false;
      var customerCenterCalled = false;

      await tester.pumpWidget(
        _buildTestWidget(
          DfSubscriptionSettingsSection(
            isWeb: true,
            onRestorePurchases: () async {
              restoreCalled = true;
              return true;
            },
            onCustomerCenter: () async {
              customerCenterCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text(strings.restorePurchasesTitle));
      await tester.pumpAndSettle();

      expect(find.text(strings.webFallbackMessage), findsOneWidget);
      expect(restoreCalled, isFalse);

      await tester.tap(find.text(strings.customerCenterTitle));
      await tester.pumpAndSettle();

      expect(find.text(strings.webFallbackMessage), findsOneWidget);
      expect(customerCenterCalled, isFalse);
    });

    testWidgets('shows error snackbar when Customer Center fails', (tester) async {
      const strings = DfSubscriptionSettingsStrings();

      await tester.pumpWidget(
        _buildTestWidget(
          DfSubscriptionSettingsSection(
            isWeb: false,
            onCustomerCenter: () async => throw Exception('Service unavailable'),
          ),
        ),
      );

      await tester.tap(find.text(strings.customerCenterTitle));
      await tester.pumpAndSettle();

      expect(
        find.text(strings.customerCenterError(Exception('Service unavailable'))),
        findsOneWidget,
      );
    });

    testWidgets('shows fallback snackbar when store link cannot be opened', (tester) async {
      const strings = DfSubscriptionSettingsStrings();

      await tester.pumpWidget(
        _buildTestWidget(
          DfSubscriptionSettingsSection(
            isWeb: false,
            platform: TargetPlatform.iOS,
            onOpenUrl: (url) async => false,
          ),
        ),
      );

      await tester.tap(find.text(strings.manageSubscriptionTitle));
      await tester.pumpAndSettle();

      expect(
        find.text(strings.storeFallback(strings.appleSubscriptionUrl)),
        findsOneWidget,
      );
    });
  });
}
