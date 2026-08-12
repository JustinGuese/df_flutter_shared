import 'package:df_theme/df_theme.dart';
import 'package:df_theme_example/brands.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Every preset must produce a usable theme in both modes. This is the cheap
  // guard against a palette that is missing a role or that throws on lerp.
  for (final brand in GalleryBrand.values) {
    testWidgets('${brand.label} builds light and dark themes', (tester) async {
      final built = brand.build();

      for (final theme in <ThemeData>[
        DfTheme.light(built),
        DfTheme.dark(built),
      ]) {
        final tokens = theme.extension<DfTokens>();
        expect(tokens, isNotNull, reason: 'DfTokens must be attached');
        expect(tokens!.brandName, built.name);

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) => Text('ok', style: context.df.dataMedium),
            ),
          ),
        );
        expect(find.text('ok'), findsOneWidget);
      }
    });
  }

  testWidgets('context.df explains itself when the theme is not wired up', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(
              () => context.df,
              throwsA(
                isA<FlutterError>().having(
                  (e) => e.message,
                  'message',
                  contains('DfTheme.light'),
                ),
              ),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
