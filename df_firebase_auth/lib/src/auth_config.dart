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
}
