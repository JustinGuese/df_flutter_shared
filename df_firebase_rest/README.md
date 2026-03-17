# df_firebase_rest

A custom generic REST implementation of Firebase Auth for Flutter.

This package provides a `FirebaseRestAuth` class that uses the Firebase Authentication REST API. It is particularly useful for platforms where the official `firebase_auth` plugin is not fully supported, such as Windows and Linux desktop applications.

## Features

- Sign in with email and password.
- Sign up with email and password.
- Secure storage of session tokens (ID token, refresh token) using `flutter_secure_storage`.
- Automatic token refresh.
- Platform-agnostic (works on Windows, Linux, Android, iOS, Web).

## Usage

```dart
import 'package:df_firebase_rest/df_firebase_rest.dart';

// Initialize the auth service
final authService = FirebaseRestAuth(apiKey: 'YOUR_FIREBASE_WEB_API_KEY');

// Listen to auth state changes
authService.authStateChanges.listen((user) {
  print('User changed: ${user?.email}');
});

// Sign in
try {
  final user = await authService.signInWithEmailAndPassword('user@example.com', 'password123');
  final idToken = await user.getIdToken();
  print('ID Token: $idToken');
} catch (e) {
  print('Error signing in: $e');
}

// Sign out
await authService.signOut();
```
