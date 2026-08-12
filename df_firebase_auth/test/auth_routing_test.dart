import 'package:df_firebase_auth/df_firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dfAuthRedirect', () {
    test('does nothing while auth is still resolving', () {
      // Redirecting here bounces the user to login and straight back, which
      // reads as a flash on every cold start.
      expect(
        dfAuthRedirect(
          location: '/diary',
          isSignedIn: false,
          isResolving: true,
        ),
        isNull,
      );
    });

    test('sends a signed-out user to login', () {
      expect(dfAuthRedirect(location: '/diary', isSignedIn: false), '/login');
    });

    test('leaves a signed-out user alone on an auth route', () {
      expect(dfAuthRedirect(location: '/login', isSignedIn: false), isNull);
      expect(dfAuthRedirect(location: '/register', isSignedIn: false), isNull);
    });

    test('matches an auth route that carries a query string', () {
      // '/login?reason=sessionExpired' must still count as an auth route, or
      // the ladder loops.
      expect(
        dfAuthRedirect(
          location: '/login?$dfSessionExpiredQuery',
          isSignedIn: false,
        ),
        isNull,
      );
    });

    test('honours public routes for signed-out users', () {
      expect(
        dfAuthRedirect(
          location: '/privacy',
          isSignedIn: false,
          publicRoutes: ['/privacy', '/terms'],
        ),
        isNull,
      );
    });

    test('sends a signed-in user off an auth route to home', () {
      expect(dfAuthRedirect(location: '/login', isSignedIn: true), '/');
    });

    test('returns a signed-in user to their ?next= target', () {
      expect(
        dfAuthRedirect(location: '/login?next=/premium', isSignedIn: true),
        '/premium',
      );
    });

    test('sends a signed-in user with unfinished onboarding to onboarding', () {
      expect(
        dfAuthRedirect(
          location: '/diary',
          isSignedIn: true,
          onboardingComplete: false,
        ),
        '/onboarding',
      );
    });

    test('does not loop once already on onboarding', () {
      expect(
        dfAuthRedirect(
          location: '/onboarding',
          isSignedIn: true,
          onboardingComplete: false,
        ),
        isNull,
      );
    });

    test('leaves a settled signed-in user alone', () {
      expect(dfAuthRedirect(location: '/diary', isSignedIn: true), isNull);
    });
  });

  group('dfSanitizeNextPath', () {
    test('accepts an internal absolute path', () {
      expect(dfSanitizeNextPath('/premium'), '/premium');
    });

    test('rejects a protocol-relative URL', () {
      // '//evil.com' is an off-site redirect wearing a path's clothing — the
      // classic open-redirect payload in a crafted login link.
      expect(dfSanitizeNextPath('//evil.com'), isNull);
    });

    test('rejects an absolute URL', () {
      expect(dfSanitizeNextPath('https://evil.com'), isNull);
    });

    test('rejects a relative path', () {
      expect(dfSanitizeNextPath('premium'), isNull);
    });

    test('rejects backslash tricks', () {
      expect(dfSanitizeNextPath(r'/\evil.com'), isNull);
    });

    test('rejects empty and null', () {
      expect(dfSanitizeNextPath(''), isNull);
      expect(dfSanitizeNextPath(null), isNull);
    });
  });

  group('session expiry', () {
    test('detects the session-expired reason', () {
      expect(dfIsSessionExpired('/login?$dfSessionExpiredQuery'), isTrue);
      expect(dfIsSessionExpired('/login'), isFalse);
      expect(dfIsSessionExpired('/login?reason=other'), isFalse);
    });
  });
}
