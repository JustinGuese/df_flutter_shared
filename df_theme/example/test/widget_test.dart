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

  // Un-migrated apps must keep working: a df_* widget dropped into a plain
  // MaterialApp has to render, not crash, or the five apps could not be
  // migrated one at a time.
  testWidgets('context.df falls back to the ambient theme', (tester) async {
    late DfTokens tokens;
    late bool wired;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF3355FF),
          brightness: Brightness.light,
        ),
        home: Builder(
          builder: (context) {
            tokens = context.df;
            wired = context.hasDfTokens;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(wired, isFalse, reason: 'no DfTokens extension was installed');
    expect(tokens.brandName, isEmpty);
    // Derived from the app's own seed, not from some other app's brand.
    expect(tokens.colors.brand.base, isNot(equals(const Color(0xFF0E6B82))));
    expect(tokens.colors.brightness, Brightness.light);
    expect(tokens.spacing.md, greaterThan(0));
  });

  testWidgets('a real brand wins over the fallback', (tester) async {
    late bool wired;
    late String name;

    await tester.pumpWidget(
      MaterialApp(
        theme: DfTheme.light(GalleryBrand.psychDiary.build()),
        home: Builder(
          builder: (context) {
            wired = context.hasDfTokens;
            name = context.df.brandName;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(wired, isTrue);
    expect(name, 'PsychDiary');
  });
}
