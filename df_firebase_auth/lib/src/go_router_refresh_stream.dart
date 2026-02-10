import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that listens to a [Stream] and notifies listeners
/// whenever the stream emits a new event.
///
/// This is primarily intended for use with `go_router`'s [GoRouter.refreshListenable]
/// to trigger route refreshes based on auth state changes:
///
/// ```dart
/// final router = GoRouter(
///   refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
///   // ...
/// );
/// ```
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

