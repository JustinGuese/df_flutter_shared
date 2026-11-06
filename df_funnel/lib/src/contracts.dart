import 'dart:async';

import 'package:df_revenuecat/df_revenuecat.dart' hide DfPaywallPresenter;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

export 'package:df_revenuecat/df_revenuecat.dart' show DfPaywallResult;

/// Steps in the initial launch funnel.
enum DfFunnelStep {
  /// User goes through onboarding screens/carousel.
  onboarding,

  /// User is shown a subscription paywall.
  paywall,

  /// User is prompted to log in or register.
  login,
}

/// Behaviour of the login step in the launch gate.
enum DfLoginMode {
  /// Authentication blocks progression into the app.
  required,

  /// Login screen is displayed with an option to skip.
  optional,

  /// Login screen is skipped during initial launch and deferred to in-app actions.
  deferred,
}

/// Callback seam for presenting a paywall.
typedef DfPaywallPresenter = Future<DfPaywallResult> Function(
  BuildContext context, {
  String? placement,
});

/// Callback seam for reading whether the active user has premium access.
typedef DfEntitlementReader = bool Function();

/// Configuration for the funnel flow and its persistence keys.
@immutable
class DfFunnelConfig {
  const DfFunnelConfig({
    this.steps = const [
      DfFunnelStep.onboarding,
      DfFunnelStep.paywall,
      DfFunnelStep.login,
    ],
    this.loginMode = DfLoginMode.deferred,
    this.paywallPlacement = 'onboarding',
    this.paywallPresenter,
    this.entitlementReader,
    this.onboardingCompletedKey = 'df_funnel_onboarding_completed',
    this.paywallCompletedKey = 'df_funnel_paywall_completed',
    this.loginCompletedKey = 'df_funnel_login_completed',
  });

  /// The ordered sequence of steps in the funnel.
  final List<DfFunnelStep> steps;

  /// How the login step is handled during the funnel.
  final DfLoginMode loginMode;

  /// Placement string passed to paywall launcher and analytics.
  final String paywallPlacement;

  /// Optional callback seam to present the paywall.
  final DfPaywallPresenter? paywallPresenter;

  /// Optional callback seam to query premium entitlement status.
  final DfEntitlementReader? entitlementReader;

  /// SharedPreferences key for recording onboarding completion.
  final String onboardingCompletedKey;

  /// SharedPreferences key for recording paywall completion/skip.
  final String paywallCompletedKey;

  /// SharedPreferences key for recording login completion/skip.
  final String loginCompletedKey;

  /// Returns a copy of this config with the given fields replaced.
  DfFunnelConfig copyWith({
    List<DfFunnelStep>? steps,
    DfLoginMode? loginMode,
    String? paywallPlacement,
    DfPaywallPresenter? paywallPresenter,
    DfEntitlementReader? entitlementReader,
    String? onboardingCompletedKey,
    String? paywallCompletedKey,
    String? loginCompletedKey,
  }) {
    return DfFunnelConfig(
      steps: steps ?? this.steps,
      loginMode: loginMode ?? this.loginMode,
      paywallPlacement: paywallPlacement ?? this.paywallPlacement,
      paywallPresenter: paywallPresenter ?? this.paywallPresenter,
      entitlementReader: entitlementReader ?? this.entitlementReader,
      onboardingCompletedKey:
          onboardingCompletedKey ?? this.onboardingCompletedKey,
      paywallCompletedKey: paywallCompletedKey ?? this.paywallCompletedKey,
      loginCompletedKey: loginCompletedKey ?? this.loginCompletedKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DfFunnelConfig &&
          runtimeType == other.runtimeType &&
          listEquals(steps, other.steps) &&
          loginMode == other.loginMode &&
          paywallPlacement == other.paywallPlacement &&
          paywallPresenter == other.paywallPresenter &&
          entitlementReader == other.entitlementReader &&
          onboardingCompletedKey == other.onboardingCompletedKey &&
          paywallCompletedKey == other.paywallCompletedKey &&
          loginCompletedKey == other.loginCompletedKey;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(steps),
        loginMode,
        paywallPlacement,
        paywallPresenter,
        entitlementReader,
        onboardingCompletedKey,
        paywallCompletedKey,
        loginCompletedKey,
      );

  @override
  String toString() =>
      'DfFunnelConfig(steps: $steps, loginMode: $loginMode, '
      'paywallPlacement: $paywallPlacement)';
}
