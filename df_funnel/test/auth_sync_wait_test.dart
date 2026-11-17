import 'package:df_funnel/df_funnel.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a spinner, then the fallback after the timeout', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DfAuthSyncWait(
          timeout: const Duration(seconds: 3),
          fallback: (_) => const Text('fallback'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('fallback'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('fallback'), findsOneWidget);
  });

  test('notPresented counts as possibly entitled', () {
    expect(DfPaywallResult.notPresented.mayBeEntitled, isTrue);
    expect(DfPaywallResult.purchased.mayBeEntitled, isTrue);
    expect(DfPaywallResult.restored.mayBeEntitled, isTrue);
    expect(DfPaywallResult.cancelled.mayBeEntitled, isFalse);
    expect(DfPaywallResult.error.mayBeEntitled, isFalse);
  });
}
