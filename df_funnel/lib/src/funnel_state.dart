import 'dart:async';

import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contracts.dart';

/// State of the launch funnel gate.
@immutable
class DfFunnelState {
  const DfFunnelState({
    this.isLoading = true,
    this.onboardingCompleted = false,
    this.paywallCompleted = false,
    this.loginCompleted = false,
    this.currentStep,
  });

  /// True while completion flags are being loaded from persistence.
  final bool isLoading;

  /// Whether onboarding has been completed or skipped.
  final bool onboardingCompleted;

  /// Whether paywall has been completed, skipped, or bypassed.
  final bool paywallCompleted;

  /// Whether login has been completed, skipped, or deferred.
  final bool loginCompleted;

  /// The active funnel step, or null if the funnel has completed.
  final DfFunnelStep? currentStep;

  /// True when loading has finished and all required funnel steps are complete.
  bool get isFunnelComplete => !isLoading && currentStep == null;

  /// Returns a copy of this state with updated properties.
  DfFunnelState copyWith({
    bool? isLoading,
    bool? onboardingCompleted,
    bool? paywallCompleted,
    bool? loginCompleted,
    DfFunnelStep? currentStep,
    bool clearCurrentStep = false,
  }) {
    return DfFunnelState(
      isLoading: isLoading ?? this.isLoading,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      paywallCompleted: paywallCompleted ?? this.paywallCompleted,
      loginCompleted: loginCompleted ?? this.loginCompleted,
      currentStep: clearCurrentStep ? null : (currentStep ?? this.currentStep),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DfFunnelState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          onboardingCompleted == other.onboardingCompleted &&
          paywallCompleted == other.paywallCompleted &&
          loginCompleted == other.loginCompleted &&
          currentStep == other.currentStep;

  @override
  int get hashCode => Object.hash(
        isLoading,
        onboardingCompleted,
        paywallCompleted,
        loginCompleted,
        currentStep,
      );

  @override
  String toString() =>
      'DfFunnelState(isLoading: $isLoading, currentStep: $currentStep, '
      'onboarding: $onboardingCompleted, paywall: $paywallCompleted, '
      'login: $loginCompleted)';
}

/// Optional override for [SharedPreferences] used by funnel controllers.
final dfFunnelSharedPreferencesProvider =
    Provider<SharedPreferences?>((ref) => null);

/// Default funnel configuration provider.
final dfFunnelConfigProvider =
    Provider<DfFunnelConfig>((ref) => const DfFunnelConfig());

/// Family notifier provider managing funnel state per configuration.
final dfFunnelProvider =
    NotifierProvider.family<DfFunnelNotifier, DfFunnelState, DfFunnelConfig>(
      DfFunnelNotifier.new,
    );

/// Convenience provider watching funnel state for [dfFunnelConfigProvider].
final dfFunnelStateProvider = Provider<DfFunnelState>((ref) {
  final config = ref.watch(dfFunnelConfigProvider);
  return ref.watch(dfFunnelProvider(config));
});

/// Controller and state manager for the launch funnel.
class DfFunnelNotifier extends Notifier<DfFunnelState> {
  DfFunnelNotifier(this.config);

  /// Funnel configuration applied to this notifier.
  final DfFunnelConfig config;

  SharedPreferences? _prefs;
  bool _tutorialBeginTracked = false;

  @override
  DfFunnelState build() {
    _prefs = ref.watch(dfFunnelSharedPreferencesProvider);
    _tutorialBeginTracked = false;
    Future.microtask(() => init(_prefs));
    return const DfFunnelState(isLoading: true);
  }

  /// Loads persisted state and recomputes the active step.
  Future<void> init([SharedPreferences? prefs]) async {
    final p = prefs ?? _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await _recomputeState(config);
  }

  Future<void> _recomputeState(DfFunnelConfig cfg) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;

    final onboardingDone = p.getBool(cfg.onboardingCompletedKey) ?? false;
    var paywallDone = p.getBool(cfg.paywallCompletedKey) ?? false;
    var loginDone = p.getBool(cfg.loginCompletedKey) ?? false;

    // Check if paywall should be auto-skipped because user is already pro.
    if (!paywallDone && (cfg.entitlementReader?.call() ?? false)) {
      paywallDone = true;
      await p.setBool(cfg.paywallCompletedKey, true);
    }

    // Check if login should be skipped because loginMode is deferred.
    if (!loginDone && cfg.loginMode == DfLoginMode.deferred) {
      loginDone = true;
      await p.setBool(cfg.loginCompletedKey, true);
    }

    DfFunnelStep? currentStep;
    for (final step in cfg.steps) {
      if (step == DfFunnelStep.onboarding && !onboardingDone) {
        currentStep = DfFunnelStep.onboarding;
        break;
      }
      if (step == DfFunnelStep.paywall && !paywallDone) {
        currentStep = DfFunnelStep.paywall;
        break;
      }
      if (step == DfFunnelStep.login && !loginDone) {
        currentStep = DfFunnelStep.login;
        break;
      }
    }

    state = DfFunnelState(
      isLoading: false,
      onboardingCompleted: onboardingDone,
      paywallCompleted: paywallDone,
      loginCompleted: loginDone,
      currentStep: currentStep,
    );

    if (currentStep == DfFunnelStep.onboarding && !_tutorialBeginTracked) {
      _tutorialBeginTracked = true;
      DfAnalyticsCore.track(DfEvents.tutorialBegin);
    }
  }

  /// Marks onboarding completed, fires analytics, and moves to the next step.
  Future<void> completeOnboarding({bool skipped = false}) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.setBool(config.onboardingCompletedKey, true);
    DfAnalyticsCore.track(DfEvents.tutorialComplete, {
      DfEventParams.skipped: skipped,
    });
    await _recomputeState(config);
  }

  /// Marks paywall completed or skipped and moves to the next step.
  Future<void> completePaywall({bool skipped = false}) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.setBool(config.paywallCompletedKey, true);
    await _recomputeState(config);
  }

  /// Marks login completed or skipped and moves to the next step.
  Future<void> completeLogin({bool skipped = false}) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.setBool(config.loginCompletedKey, true);
    await _recomputeState(config);
  }

  /// Skips the specified step if permitted by configuration.
  Future<void> skipStep(DfFunnelStep step) async {
    switch (step) {
      case DfFunnelStep.onboarding:
        await completeOnboarding(skipped: true);
      case DfFunnelStep.paywall:
        await completePaywall(skipped: true);
      case DfFunnelStep.login:
        if (config.loginMode == DfLoginMode.required) return;
        await completeLogin(skipped: true);
    }
  }

  /// Completes the currently active step.
  Future<void> completeCurrentStep({bool skipped = false}) async {
    final step = state.currentStep;
    if (step == null) return;
    if (skipped) {
      await skipStep(step);
    } else {
      switch (step) {
        case DfFunnelStep.onboarding:
          await completeOnboarding();
        case DfFunnelStep.paywall:
          await completePaywall();
        case DfFunnelStep.login:
          await completeLogin();
      }
    }
  }

  /// Resets all funnel persistence keys.
  Future<void> reset() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.remove(config.onboardingCompletedKey);
    await p.remove(config.paywallCompletedKey);
    await p.remove(config.loginCompletedKey);
    _tutorialBeginTracked = false;
    await _recomputeState(config);
  }
}
