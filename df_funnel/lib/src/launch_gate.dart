import 'dart:async';

import 'package:df_revenuecat/df_revenuecat.dart' hide DfPaywallPresenter;
import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contracts.dart';
import 'funnel_state.dart';

/// Builder callback for funnel steps providing context and a completion callback.
typedef DfStepBuilder = Widget Function(
  BuildContext context,
  VoidCallback onComplete,
);

/// Inherited scope providing access to [DfFunnelState] and [DfFunnelNotifier].
class DfFunnelScope extends InheritedWidget {
  const DfFunnelScope({
    super.key,
    required this.state,
    required this.notifier,
    required super.child,
  });

  /// The current snapshot of the funnel state.
  final DfFunnelState state;

  /// The notifier controlling funnel progression.
  final DfFunnelNotifier notifier;

  /// Finds the closest [DfFunnelScope] in the widget tree.
  static DfFunnelScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DfFunnelScope>();
    assert(scope != null, 'No DfFunnelScope found in context');
    return scope!;
  }

  /// Finds the closest [DfFunnelScope] in the widget tree, or null.
  static DfFunnelScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DfFunnelScope>();
  }

  /// Marks onboarding completed.
  void completeOnboarding({bool skipped = false}) =>
      notifier.completeOnboarding(skipped: skipped);

  /// Marks paywall completed.
  void completePaywall({bool skipped = false}) =>
      notifier.completePaywall(skipped: skipped);

  /// Marks login completed.
  void completeLogin({bool skipped = false}) =>
      notifier.completeLogin(skipped: skipped);

  /// Skips the specified step if permitted.
  void skipStep(DfFunnelStep step) => notifier.skipStep(step);

  /// Completes or skips the active step.
  void completeCurrentStep({bool skipped = false}) =>
      notifier.completeCurrentStep(skipped: skipped);

  @override
  bool updateShouldNotify(DfFunnelScope oldWidget) =>
      state != oldWidget.state || notifier != oldWidget.notifier;
}

/// Gate widget that sequences onboarding, paywall, and login before displaying home.
///
/// Steps are executed in the order defined by [DfFunnelConfig.steps]:
/// 1. Onboarding: persists done flag and emits tutorialBegin / tutorialComplete events.
/// 2. Paywall: skippable; skipped automatically if already pro via [DfFunnelConfig.entitlementReader].
/// 3. Login: handled according to [DfLoginMode] (required blocks, optional shows skippable, deferred skips).
/// 4. Home: built via [homeBuilder] once all funnel steps are satisfied.
class DfLaunchGate extends ConsumerStatefulWidget {
  const DfLaunchGate({
    super.key,
    this.homeBuilder,
    this.child,
    this.config,
    this.onboardingBuilder,
    this.paywallBuilder,
    this.loginBuilder,
    this.loadingBuilder,
  }) : assert(
          homeBuilder != null || child != null,
          'Either homeBuilder or child must be provided',
        );

  /// Builder for the main app view displayed after the funnel completes.
  final WidgetBuilder? homeBuilder;

  /// Main app widget displayed after the funnel completes (alternative to homeBuilder).
  final Widget? child;

  /// Optional funnel configuration overriding ambient [dfFunnelConfigProvider].
  final DfFunnelConfig? config;

  /// Custom builder for the onboarding step.
  final DfStepBuilder? onboardingBuilder;

  /// Custom builder for the paywall step.
  final DfStepBuilder? paywallBuilder;

  /// Custom builder for the login step.
  final DfStepBuilder? loginBuilder;

  /// Custom builder shown while funnel state is loading.
  final WidgetBuilder? loadingBuilder;

  @override
  ConsumerState<DfLaunchGate> createState() => _DfLaunchGateState();
}

class _DfLaunchGateState extends ConsumerState<DfLaunchGate> {
  @override
  Widget build(BuildContext context) {
    final DfFunnelConfig effectiveConfig =
        widget.config ?? ref.watch(dfFunnelConfigProvider);
    final funnelState = ref.watch(dfFunnelProvider(effectiveConfig));
    final notifier = ref.read(dfFunnelProvider(effectiveConfig).notifier);

    Widget content;
    if (funnelState.isLoading) {
      content = widget.loadingBuilder?.call(context) ??
          const _DefaultLoadingView();
    } else if (funnelState.isFunnelComplete) {
      content = widget.homeBuilder?.call(context) ?? widget.child!;
    } else {
      switch (funnelState.currentStep) {
        case DfFunnelStep.onboarding:
          content = widget.onboardingBuilder?.call(
                context,
                () => notifier.completeOnboarding(),
              ) ??
              _DefaultOnboardingStep(
                onComplete: () => notifier.completeOnboarding(),
                onSkip: () => notifier.completeOnboarding(skipped: true),
              );
        case DfFunnelStep.paywall:
          content = widget.paywallBuilder?.call(
                context,
                () => notifier.completePaywall(),
              ) ??
              _DefaultPaywallStep(
                config: effectiveConfig,
                onComplete: () => notifier.completePaywall(),
                onSkip: () => notifier.completePaywall(skipped: true),
              );
        case DfFunnelStep.login:
          content = widget.loginBuilder?.call(
                context,
                () => notifier.completeLogin(),
              ) ??
              _DefaultLoginStep(
                mode: effectiveConfig.loginMode,
                onComplete: () => notifier.completeLogin(),
                onSkip: () => notifier.completeLogin(skipped: true),
              );
        case null:
          content = widget.homeBuilder?.call(context) ?? widget.child!;
      }
    }

    return DfFunnelScope(
      state: funnelState,
      notifier: notifier,
      child: content,
    );
  }
}

class _DefaultLoadingView extends StatelessWidget {
  const _DefaultLoadingView();

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Scaffold(
      key: const Key('df_funnel_loading_spinner'),
      backgroundColor: df.colors.canvas,
      body: Center(
        child: CircularProgressIndicator(
          color: df.colors.brand.base,
        ),
      ),
    );
  }
}

class _DefaultOnboardingStep extends StatelessWidget {
  const _DefaultOnboardingStep({
    required this.onComplete,
    required this.onSkip,
  });

  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: const Key('df_funnel_onboarding_step'),
      backgroundColor: df.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(df.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.explore_outlined,
                size: 72,
                color: df.colors.brand.base,
              ),
              SizedBox(height: df.spacing.lg),
              Text(
                'Welcome',
                style: textTheme.headlineMedium?.copyWith(
                  color: df.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: df.spacing.sm),
              Text(
                'Discover stories and insights crafted for you.',
                style: textTheme.bodyLarge?.copyWith(
                  color: df.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                key: const Key('df_funnel_onboarding_complete_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: df.colors.brand.base,
                  foregroundColor: df.colors.textOnBrand,
                  padding: EdgeInsets.symmetric(vertical: df.spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: df.shape.radiusButton,
                  ),
                ),
                onPressed: onComplete,
                child: const Text('Get Started'),
              ),
              SizedBox(height: df.spacing.sm),
              TextButton(
                key: const Key('df_funnel_onboarding_skip_button'),
                onPressed: onSkip,
                child: Text(
                  'Skip',
                  style: TextStyle(color: df.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultPaywallStep extends StatefulWidget {
  const _DefaultPaywallStep({
    required this.config,
    required this.onComplete,
    required this.onSkip,
  });

  final DfFunnelConfig config;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  State<_DefaultPaywallStep> createState() => _DefaultPaywallStepState();
}

class _DefaultPaywallStepState extends State<_DefaultPaywallStep> {
  bool _isInvoking = false;

  Future<void> _handlePaywall() async {
    if (_isInvoking) return;
    setState(() => _isInvoking = true);
    try {
      if (widget.config.paywallPresenter != null) {
        await widget.config.paywallPresenter!(
          context,
          placement: widget.config.paywallPlacement,
        );
        if (mounted) {
          widget.onComplete();
        }
      } else {
        await DfPaywallLauncher.show(
          context,
          placement: widget.config.paywallPlacement,
        );
        if (mounted) {
          widget.onComplete();
        }
      }
    } catch (_) {
      if (mounted) widget.onComplete();
    } finally {
      if (mounted) setState(() => _isInvoking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: const Key('df_funnel_paywall_step'),
      backgroundColor: df.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(df.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.stars_rounded,
                size: 72,
                color: df.colors.brand.base,
              ),
              SizedBox(height: df.spacing.lg),
              Text(
                'Unlock Premium Access',
                style: textTheme.headlineMedium?.copyWith(
                  color: df.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: df.spacing.sm),
              Text(
                'Get unlimited access to all features and exclusive content.',
                style: textTheme.bodyLarge?.copyWith(
                  color: df.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                key: const Key('df_funnel_paywall_continue_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: df.colors.brand.base,
                  foregroundColor: df.colors.textOnBrand,
                  padding: EdgeInsets.symmetric(vertical: df.spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: df.shape.radiusButton,
                  ),
                ),
                onPressed: _isInvoking ? null : _handlePaywall,
                child: Text(_isInvoking ? 'Loading...' : 'View Plans'),
              ),
              SizedBox(height: df.spacing.sm),
              TextButton(
                key: const Key('df_funnel_paywall_skip_button'),
                onPressed: widget.onSkip,
                child: Text(
                  'Maybe Later',
                  style: TextStyle(color: df.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultLoginStep extends StatelessWidget {
  const _DefaultLoginStep({
    required this.mode,
    required this.onComplete,
    required this.onSkip,
  });

  final DfLoginMode mode;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final textTheme = Theme.of(context).textTheme;
    final canSkip = mode == DfLoginMode.optional;

    return Scaffold(
      key: const Key('df_funnel_login_step'),
      backgroundColor: df.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(df.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.account_circle_outlined,
                size: 72,
                color: df.colors.brand.base,
              ),
              SizedBox(height: df.spacing.lg),
              Text(
                'Sign In',
                style: textTheme.headlineMedium?.copyWith(
                  color: df.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: df.spacing.sm),
              Text(
                canSkip
                    ? 'Sign in to sync your progress across devices, or skip for now.'
                    : 'Sign in to access your account and continue.',
                style: textTheme.bodyLarge?.copyWith(
                  color: df.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                key: const Key('df_funnel_login_submit_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: df.colors.brand.base,
                  foregroundColor: df.colors.textOnBrand,
                  padding: EdgeInsets.symmetric(vertical: df.spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: df.shape.radiusButton,
                  ),
                ),
                onPressed: onComplete,
                child: const Text('Sign In'),
              ),
              if (canSkip) ...[
                SizedBox(height: df.spacing.sm),
                TextButton(
                  key: const Key('df_funnel_login_skip_button'),
                  onPressed: onSkip,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(color: df.colors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
