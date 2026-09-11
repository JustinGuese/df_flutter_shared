import 'package:flutter/foundation.dart';

/// Configuration for Firebase Auth and API client.
@immutable
class AuthConfig {
  const AuthConfig({
    required this.apiBaseUrl,
    this.serverClientId,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
    this.appName = 'App',
    this.logoAssetPath = 'assets/images/logo.png',
    this.homeRoute = '/',
    this.loginRoute = '/login',
    this.registerRoute = '/register',
    this.onRegistered,
  });

  final String apiBaseUrl;
  final String? serverClientId;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String appName;
  final String logoAssetPath;
  final String homeRoute;
  final String loginRoute;
  final String registerRoute;

  /// Called once when a brand-new account is created, on whichever screen it
  /// happened — a social sign-in from the login screen registers a first-time
  /// user just as the register screen does.
  ///
  /// Not needed for analytics: [AuthRepository] reports `sign_up` (and `login`,
  /// `auth_failed`) to df_analytics_core on its own, and df_analytics maps
  /// `sign_up` to Meta's CompleteRegistration. Wiring an analytics call here as
  /// well counts every registration twice. Keep this for non-analytics side
  /// effects only.
  final VoidCallback? onRegistered;
}
