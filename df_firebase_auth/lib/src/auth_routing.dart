import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The redirect ladder every DF app was writing by hand.
///
/// PsychDiary, SocialAnxify and NaviCare each had their own copy of this,
/// including the same `?reason=sessionExpired` string. The rules are:
///
///  1. Still deciding whether the user is signed in → stay put.
///  2. Signed out, and not already on an auth route → go to login.
///  3. Signed in, but sitting on an auth route → go home.
///  4. Signed in and onboarding is unfinished → go to onboarding.
///  5. Otherwise → no redirect.
///
/// Returns the path to redirect to, or null to stay. App-specific gates (a
/// character to create, a profile to complete) layer on top of the result
/// rather than inside it — see the example in the README.
String? dfAuthRedirect({
  required String location,
  required bool isSignedIn,
  bool isResolving = false,
  bool onboardingComplete = true,
  String loginRoute = '/login',
  String homeRoute = '/',
  String onboardingRoute = '/onboarding',
  List<String> authRoutes = const <String>['/login', '/register', '/reset'],
  List<String> publicRoutes = const <String>[],
}) {
  // Redirecting while auth is still resolving bounces the user to login and
  // straight back, which reads as a flash on every cold start.
  if (isResolving) return null;

  bool matches(List<String> routes) =>
      routes.any((r) => location == r || location.startsWith('$r?'));

  final onAuthRoute = matches(authRoutes);

  if (!isSignedIn) {
    if (onAuthRoute || matches(publicRoutes)) return null;
    return loginRoute;
  }

  if (!onboardingComplete && location != onboardingRoute) {
    return onboardingRoute;
  }

  if (onAuthRoute) {
    // Honour ?next= so a paywall bounce returns where it started.
    return dfSafeNextPath(location) ?? homeRoute;
  }

  return null;
}

/// Extracts a `?next=` target from [location] when it is safe to use.
///
/// Only internal absolute paths are accepted. A value starting with `//` is a
/// protocol-relative URL and would send the user to another origin after
/// login — an open-redirect, and exactly the kind of thing an attacker puts in
/// a crafted link.
String? dfSafeNextPath(String location) {
  final next = Uri.tryParse(location)?.queryParameters['next'];
  return dfSanitizeNextPath(next);
}

/// The path to go to after a successful sign-in or registration.
///
/// Reads `?next=` from the current route, falling back to [fallback].
String dfPostAuthDestination(BuildContext context, {String fallback = '/'}) {
  final next = GoRouterState.of(context).uri.queryParameters['next'];
  return dfSanitizeNextPath(next) ?? fallback;
}

/// Returns [next] when it is a safe internal path, else null.
String? dfSanitizeNextPath(String? next) {
  if (next == null || next.isEmpty) return null;
  if (!next.startsWith('/')) return null;
  // Protocol-relative — an off-site redirect wearing a path's clothing.
  if (next.startsWith('//')) return null;
  if (next.contains('\\')) return null;
  return next;
}

/// The query string appended when a session expires, so the login screen can
/// explain why the user is suddenly there.
const String dfSessionExpiredQuery = 'reason=sessionExpired';

/// True when the login route was reached because the session expired.
bool dfIsSessionExpired(String location) =>
    Uri.tryParse(location)?.queryParameters['reason'] == 'sessionExpired';
