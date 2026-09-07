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
  /// Exists so an app can report a registration to analytics without the
  /// package knowing what it reports to.
  final VoidCallback? onRegistered;
}
