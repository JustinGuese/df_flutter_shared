import 'package:df_revenuecat/df_revenuecat.dart' hide DfPaywallPresenter;
import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contracts.dart';
import 'pro_widgets.dart';

export 'pro_widgets.dart';

/// Provider for checking whether the user currently holds premium entitlement.
/// Defaults to watching [dfRevenueCatIsProProvider].
final dfPremiumAccessProvider = Provider<bool>((ref) {
  return ref.watch(dfRevenueCatIsProProvider);
});

/// Ensures the user has premium entitlement before proceeding.
///
/// Returns `true` if already entitled or if the user successfully unlocked
/// via the presented paywall. Returns `false` if dismissed without purchasing.
Future<bool> requirePremium(
  BuildContext context,
  WidgetRef ref, [
  String? placement,
  DfPaywallPresenter? paywallPresenter,
  DfEntitlementReader? isEntitled,
]) async {
  final currentEntitled = isEntitled != null
      ? isEntitled()
      : ref.read(dfPremiumAccessProvider);

  if (currentEntitled) {
    return true;
  }

  final result = paywallPresenter != null
      ? await paywallPresenter(context, placement: placement)
      : await DfPaywallLauncher.show(
          context,
          placement: placement ?? 'require_premium',
        );

  final refreshedEntitled = isEntitled != null
      ? isEntitled()
      : ref.read(dfPremiumAccessProvider);

  return result.isSuccess || refreshedEntitled;
}

/// Gate widget displaying [child] when entitled, or a lock overlay otherwise.
///
/// Tapping the locked state opens the paywall and re-checks entitlement on return.
class DfPremiumGate extends ConsumerStatefulWidget {
  const DfPremiumGate({
    super.key,
    required this.child,
    this.lockedBuilder,
    this.placement,
    this.paywallPresenter,
    this.entitlementReader,
    this.strings = const DfFunnelStrings(),
  });

  /// The entitled content protected by this gate.
  final Widget child;

  /// Optional custom builder for the locked state.
  final WidgetBuilder? lockedBuilder;

  /// Placement identifier sent to paywall presentations and analytics.
  final String? placement;

  /// Optional callback seam for paywall presentation (useful in tests).
  final DfPaywallPresenter? paywallPresenter;

  /// Optional callback seam for querying entitlement status.
  final DfEntitlementReader? entitlementReader;

  /// Strings used for copy in the default lock overlay.
  final DfFunnelStrings strings;

  @override
  ConsumerState<DfPremiumGate> createState() => _DfPremiumGateState();
}

class _DfPremiumGateState extends ConsumerState<DfPremiumGate> {
  bool _isOpeningPaywall = false;
  bool _locallyUnlocked = false;

  Future<void> _handleLockedTap() async {
    if (_isOpeningPaywall) return;
    _isOpeningPaywall = true;

    try {
      final result = widget.paywallPresenter != null
          ? await widget.paywallPresenter!(
              context,
              placement: widget.placement,
            )
          : await DfPaywallLauncher.show(
              context,
              placement: widget.placement ?? 'premium_gate',
            );

      if (!mounted) return;

      final isReaderEntitled = widget.entitlementReader?.call() ?? false;
      if (result.isSuccess || isReaderEntitled) {
        setState(() {
          _locallyUnlocked = true;
        });
      }
    } finally {
      if (mounted) {
        _isOpeningPaywall = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEntitled = _locallyUnlocked ||
        (widget.entitlementReader != null
            ? widget.entitlementReader!()
            : ref.watch(dfPremiumAccessProvider));

    if (isEntitled) {
      return widget.child;
    }

    if (widget.lockedBuilder != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleLockedTap,
        child: widget.lockedBuilder!(context),
      );
    }

    return _buildDefaultLockedOverlay(context);
  }

  Widget _buildDefaultLockedOverlay(BuildContext context) {
    final df = context.df;
    final theme = Theme.of(context);

    return InkWell(
      onTap: _handleLockedTap,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(df.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(df.spacing.md),
                decoration: BoxDecoration(
                  color: df.colors.brand.base.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: df.colors.brand.base,
                  size: 28,
                ),
              ),
              SizedBox(height: df.spacing.sm),
              Text(
                widget.strings.lockedTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: df.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: df.spacing.xs),
              Text(
                widget.strings.lockedSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: df.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
