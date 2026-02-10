# df_firebase_auth

Reusable Firebase Auth package: `AuthRepository`, `ApiClient`, login/register screens, and Riverpod auth providers. Override `authConfigProvider` in your app with API URL, server client ID, logo path, app name, and routes. Used in apps by [DataFortress.cloud](https://datafortress.cloud/).

---

## What’s included

- **AuthConfig / authConfigProvider** – App-level configuration: `apiBaseUrl`, `serverClientId`, timeouts, app name, logo, and routes (`homeRoute`, `loginRoute`, `registerRoute`).
- **AuthRepository** – Email/password, Google, Apple sign-in, password reset, sign-out.
- **ApiClient** – Dio client that:
  - Injects Firebase ID tokens into the `Authorization` header.
  - Automatically refreshes tokens and retries on `401` when appropriate.
- **Widgets** – `LoginScreen`, `RegisterScreen`, and `GoogleIcon`.
- **GoRouterRefreshStream** – A small `ChangeNotifier` that wraps a `Stream` and is suitable for `GoRouter.refreshListenable`.

---

## Using GoRouterRefreshStream

Use `GoRouterRefreshStream` to make your `GoRouter` react to auth state changes (login/logout) without writing a custom `ChangeNotifier`:

```dart
import 'package:df_firebase_auth/df_firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      // ...
    ],
  );
});
```

This helper is also used in DocumentChat-style apps to keep routes in sync with Firebase authentication without duplicating boilerplate in each project.
