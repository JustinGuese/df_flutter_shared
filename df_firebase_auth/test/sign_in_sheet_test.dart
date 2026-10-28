import 'package:df_firebase_auth/df_firebase_auth.dart';
import 'package:df_theme/df_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  bool googleCalled = false;
  bool appleCalled = false;
  Object? errorToThrow;

  @override
  Future<UserCredential> signInWithGoogle() async {
    if (errorToThrow != null) throw errorToThrow!;
    googleCalled = true;
    return FakeUserCredential();
  }

  @override
  Future<UserCredential> signInWithApple() async {
    if (errorToThrow != null) throw errorToThrow!;
    appleCalled = true;
    return FakeUserCredential();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget buildTestWidget({
  required Widget child,
  required AuthRepository authRepo,
}) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
    child: MaterialApp(
      theme: DfTheme.light(DfBrandPresets.dataFortress()),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('DfSignInSheetStrings', () {
    test('default strings and fill', () {
      const strings = DfSignInSheetStrings();
      expect(strings.title, 'Save your progress across devices');
      expect(strings.googleButton, 'Continue with Google');
      expect(strings.appleButton, 'Continue with Apple');
      expect(strings.notNowButton, 'Not now');

      expect(
        strings.fillGoogleFailed('network error'),
        'Google Sign-In failed: network error',
      );
      expect(
        strings.fillAppleFailed('cancelled'),
        'Apple Sign-In failed: cancelled',
      );
    });

    test('copyWith overrides values', () {
      const strings = DfSignInSheetStrings();
      final custom = strings.copyWith(
        title: 'Custom Title',
        googleButton: 'Google In',
      );
      expect(custom.title, 'Custom Title');
      expect(custom.googleButton, 'Google In');
      expect(custom.appleButton, strings.appleButton);
    });
  });

  group('DfSignInSheet widget', () {
    late FakeAuthRepository authRepo;

    setUp(() {
      authRepo = FakeAuthRepository();
    });

    testWidgets('renders defaults correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const DfSignInSheet(), authRepo: authRepo),
      );

      expect(find.text('Save your progress across devices'), findsOneWidget);
      expect(
        find.text(
          'Sign in securely with Google or Apple to keep your data in sync.',
        ),
        findsOneWidget,
      );
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('renders custom strings', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const DfSignInSheet(
            strings: DfSignInSheetStrings(
              title: 'Keep your picks & bookmarks across devices',
              subtitle: 'Sign in to sync your feed.',
            ),
          ),
          authRepo: authRepo,
        ),
      );

      expect(
        find.text('Keep your picks & bookmarks across devices'),
        findsOneWidget,
      );
      expect(find.text('Sign in to sync your feed.'), findsOneWidget);
    });

    testWidgets('Google sign-in button triggers auth and closes sheet', (
      tester,
    ) async {
      bool onSignedInCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DfSignInSheet.show(
                context,
                onSignedIn: () => onSignedInCalled = true,
              ),
              child: const Text('Open'),
            ),
          ),
          authRepo: authRepo,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(authRepo.googleCalled, isTrue);
      expect(onSignedInCalled, isTrue);
      // Sheet was popped
      expect(find.text('Continue with Google'), findsNothing);
    });

    testWidgets('Apple sign-in button triggers auth and closes sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DfSignInSheet.show(context),
              child: const Text('Open'),
            ),
          ),
          authRepo: authRepo,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Continue with Apple'), findsOneWidget);
      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(authRepo.appleCalled, isTrue);
      expect(find.text('Continue with Apple'), findsNothing);
    });

    testWidgets('Not now dismisses the sheet', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DfSignInSheet.show(context),
              child: const Text('Open'),
            ),
          ),
          authRepo: authRepo,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(find.text('Not now'), findsNothing);
      expect(authRepo.googleCalled, isFalse);
      expect(authRepo.appleCalled, isFalse);
    });
  });
}
