import 'dart:async';

import 'package:df_funnel/src/contracts.dart';
import 'package:df_funnel/src/premium_gate.dart';
import 'package:df_funnel/src/pro_widgets.dart';
import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DfPremiumGate', () {
    testWidgets('shows child directly when user is entitled', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          DfPremiumGate(
            entitlementReader: () => true,
            child: const Text('Entitled Content'),
          ),
        ),
      );

      expect(find.text('Entitled Content'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });

    testWidgets('locked tap opens paywall exactly once even on rapid taps', (
      tester,
    ) async {
      var callCount = 0;
      final completer = Completer<DfPaywallResult>();

      Future<DfPaywallResult> mockPresenter(
        BuildContext context, {
        String? placement,
      }) {
        callCount++;
        return completer.future;
      }

      await tester.pumpWidget(
        _buildTestApp(
          DfPremiumGate(
            entitlementReader: () => false,
            paywallPresenter: mockPresenter,
            child: const Text('Entitled Content'),
          ),
        ),
      );

      // Verify locked state is visible
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.text('Unlock with Pro'), findsOneWidget);

      // Rapidly tap the locked gate twice
      await tester.tap(find.text('Unlock with Pro'));
      await tester.tap(find.text('Unlock with Pro'));
      await tester.pump();

      // Only one paywall presentation was started
      expect(callCount, equals(1));

      // Resolve the paywall
      completer.complete(DfPaywallResult.cancelled);
      await tester.pumpAndSettle();

      expect(callCount, equals(1));
    });

    testWidgets('unlocks and renders child after successful purchase', (
      tester,
    ) async {
      var isEntitled = false;

      Future<DfPaywallResult> mockPresenter(
        BuildContext context, {
        String? placement,
      }) async {
        isEntitled = true;
        return DfPaywallResult.purchased;
      }

      await tester.pumpWidget(
        _buildTestApp(
          DfPremiumGate(
            entitlementReader: () => isEntitled,
            paywallPresenter: mockPresenter,
            child: const Text('Unlocked Secret'),
          ),
        ),
      );

      expect(find.text('Unlocked Secret'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      // Tap lock overlay to trigger purchase flow
      await tester.tap(find.text('Unlock with Pro'));
      await tester.pumpAndSettle();

      // Gate has unlocked and displays child
      expect(find.text('Unlocked Secret'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });
  });

  group('requirePremium', () {
    testWidgets('returns true without opening paywall if already entitled', (
      tester,
    ) async {
      bool? result;
      var paywallCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: () async {
                  result = await requirePremium(
                    context,
                    ref,
                    'test_placement',
                    (ctx, {placement}) async {
                      paywallCalled = true;
                      return DfPaywallResult.purchased;
                    },
                    () => true,
                  );
                },
                child: const Text('Action'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(paywallCalled, isFalse);
    });

    testWidgets('returns true on purchase and false on cancel when unentitled', (
      tester,
    ) async {
      bool? purchaseResult;
      bool? cancelResult;

      await tester.pumpWidget(
        _buildTestApp(
          Consumer(
            builder: (context, ref, _) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      purchaseResult = await requirePremium(
                        context,
                        ref,
                        'buy',
                        (ctx, {placement}) async => DfPaywallResult.purchased,
                        () => false,
                      );
                    },
                    child: const Text('Buy'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      cancelResult = await requirePremium(
                        context,
                        ref,
                        'cancel',
                        (ctx, {placement}) async => DfPaywallResult.cancelled,
                        () => false,
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();
      expect(purchaseResult, isTrue);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cancelResult, isFalse);
    });
  });

  group('DfUpsellSheet cooldown', () {
    testWidgets('blocks subsequent presentations during cooldown duration', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      const cooldown = DfCooldown(
        key: 'test_upsell_cooldown',
        duration: Duration(hours: 12),
      );

      bool? firstShowResult;
      bool? secondShowResult;

      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      firstShowResult = await DfUpsellSheet.maybeShow(
                        context,
                        cooldown: cooldown,
                        prefs: prefs,
                      );
                    },
                    child: const Text('First Show'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      secondShowResult = await DfUpsellSheet.maybeShow(
                        context,
                        cooldown: cooldown,
                        prefs: prefs,
                      );
                    },
                    child: const Text('Second Show'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // First call succeeds and presents sheet
      await tester.tap(find.text('First Show'));
      await tester.pumpAndSettle();

      expect(find.byType(DfUpsellSheet), findsOneWidget);

      // Dismiss the bottom sheet
      await tester.tap(find.text('Maybe later'));
      await tester.pumpAndSettle();

      expect(firstShowResult, isTrue);
      expect(find.byType(DfUpsellSheet), findsNothing);

      // Second call immediately afterwards is blocked by cooldown
      await tester.tap(find.text('Second Show'));
      await tester.pumpAndSettle();

      expect(secondShowResult, isFalse);
      expect(find.byType(DfUpsellSheet), findsNothing);

      // Reset cooldown and try again
      await cooldown.reset(prefs: prefs);
      bool? thirdShowResult;
      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  thirdShowResult = await DfUpsellSheet.maybeShow(
                    context,
                    cooldown: cooldown,
                    prefs: prefs,
                  );
                },
                child: const Text('Third Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Third Show'));
      await tester.pumpAndSettle();

      expect(find.byType(DfUpsellSheet), findsOneWidget);

      await tester.tap(find.text('Maybe later'));
      await tester.pumpAndSettle();

      expect(thirdShowResult, isTrue);
    });
  });
}
