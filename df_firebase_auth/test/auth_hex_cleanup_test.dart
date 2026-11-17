import 'package:df_firebase_auth/df_firebase_auth.dart';
import 'package:df_theme/df_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('AssetManifest.bin')) {
      final ByteData data = const StandardMessageCodec().encodeMessage(
        <String, Object?>{'assets/images/logo.png': <Object?>[]},
      )!;
      return data;
    }
    if (key.endsWith('AssetManifest.json')) {
      return ByteData.sublistView(Uint8List.fromList('{}'.codeUnits));
    }
    // 1x1 transparent PNG
    final bytes = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);
    return ByteData.sublistView(bytes);
  }
}

void main() {
  const customBorderColor = Color(0xFF123456);

  Widget createTestApp({
    required Widget child,
    Color borderColor = customBorderColor,
  }) {
    final brand = DfBrandPresets.dataFortress();
    final tokens = DfTokens.derivedFrom(ThemeData.light()).copyWith(
      colors: DfPalette.fromColorScheme(
        const ColorScheme.light(),
      ).copyWith(border: borderColor),
    );

    final theme = DfTheme.light(brand).copyWith(extensions: [tokens]);

    return ProviderScope(
      overrides: [
        authConfigProvider.overrideWithValue(
          const AuthConfig(
            apiBaseUrl: 'https://api.example.com',
            appName: 'TestApp',
          ),
        ),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
      child: MaterialApp(
        theme: theme,
        home: DefaultAssetBundle(bundle: _TestAssetBundle(), child: child),
      ),
    );
  }

  testWidgets('LoginScreen Google button uses context.df.colors.border', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(child: const LoginScreen()));
    await tester.pump();

    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Sign in with Google'),
    );
    final side = button.style?.side?.resolve({});
    expect(side, isNotNull);
    expect(side!.color, customBorderColor);
  });

  testWidgets('RegisterScreen Google button uses context.df.colors.border', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(child: const RegisterScreen()));
    await tester.pump();

    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Sign up with Google'),
    );
    final side = button.style?.side?.resolve({});
    expect(side, isNotNull);
    expect(side!.color, customBorderColor);
  });

  testWidgets('GoogleIcon renders without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: GoogleIcon())),
      ),
    );
    expect(find.byType(GoogleIcon), findsOneWidget);
  });
}
