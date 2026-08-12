import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'paywall_config.dart';
import 'paywall_subscription_info.dart';

/// Full-page premium/subscription management screen.
///
/// Renders two layouts automatically:
/// - **Not premium**: hero + feature list + CTA (upsell)
/// - **Premium**: membership confirmation + trial countdown + "Manage" button
///
/// The caller provides callbacks for [onUpgrade] and [onManageSubscription] so
/// the widget remains decoupled from any payment SDK.
///
/// Example:
/// ```dart
/// PaywallPremiumScreen(
///   config: myConfig,
///   subscriptionInfo: sub,
///   onUpgrade: () => subscriptionService.startCheckout(),
///   onManageSubscription: () => subscriptionService.openPortal(),
/// )
/// ```
class PaywallPremiumScreen extends StatefulWidget {
  final PaywallConfig config;
  final PaywallSubscriptionInfo subscriptionInfo;
  final Future<void> Function() onUpgrade;
  final Future<void> Function()? onManageSubscription;

  const PaywallPremiumScreen({
    super.key,
    required this.config,
    required this.subscriptionInfo,
    required this.onUpgrade,
    this.onManageSubscription,
  });

  @override
  State<PaywallPremiumScreen> createState() => _PaywallPremiumScreenState();
}

class _PaywallPremiumScreenState extends State<PaywallPremiumScreen> {
  bool _loadingUpgrade = false;
  bool _loadingPortal = false;

  Future<void> _handleUpgrade() async {
    setState(() => _loadingUpgrade = true);
    try {
      await widget.onUpgrade();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.config.checkoutErrorText)),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingUpgrade = false);
    }
  }

  Future<void> _handlePortal() async {
    setState(() => _loadingPortal = true);
    try {
      await widget.onManageSubscription?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.config.portalErrorText)));
      }
    } finally {
      if (mounted) setState(() => _loadingPortal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.subscriptionInfo;
    return sub.isPremium ? _buildPremiumView(sub) : _buildUpsellView();
  }

  Widget _buildUpsellView() {
    final cfg = widget.config;
    final df = context.df;
    final accent = cfg.accentColor ?? df.colors.brand.base;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          _HeroCard(config: cfg),
          const SizedBox(height: 20),
          // Price card
          _PriceCard(config: cfg),
          const SizedBox(height: 16),
          // Feature list card
          _FeatureCard(config: cfg),
          const SizedBox(height: 24),
          // CTA
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _loadingUpgrade ? null : _handleUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: df.colors.textOnBrand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _loadingUpgrade
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: df.colors.textOnBrand,
                      ),
                    )
                  : Text(
                      cfg.ctaText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumView(PaywallSubscriptionInfo sub) {
    final cfg = widget.config;
    final df = context.df;
    final accent = cfg.accentColor ?? df.colors.brand.base;
    final gradientColors = cfg.gradient ?? df.gradientStops('hero');
    final onGradient = df.onGradient('hero');
    final daysLeft = sub.trialDaysRemaining;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active membership card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('✅', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  cfg.fill(cfg.memberHeadline),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onGradient,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (sub.isTrialing && daysLeft != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: df.colors.warning.base.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      cfg.fill(cfg.trialDaysRemainingLabel, days: daysLeft),
                      style: TextStyle(
                        color: df.colors.warning.base,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Period info
          if (sub.currentPeriodEnd != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: df.colors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: accent),
                  const SizedBox(width: 10),
                  Text(
                    sub.isTrialing && sub.trialEnd != null
                        ? '${cfg.trialEndsLabel}: ${_fmtDate(sub.trialEnd!)}'
                        : '${cfg.nextBillingLabel}: ${_fmtDate(sub.currentPeriodEnd!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: df.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (sub.currentPeriodEnd != null) const SizedBox(height: 16),
          // Manage button (Stripe Billing Portal or equivalent)
          if (widget.onManageSubscription != null)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loadingPortal ? null : _handlePortal,
                icon: _loadingPortal
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: df.colors.textOnBrand,
                        ),
                      )
                    : const Icon(Icons.open_in_new, size: 18),
                label: Text(cfg.manageSubscriptionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: df.colors.textOnBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            cfg.portalHintText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: df.colors.textTertiary),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final PaywallConfig config;
  const _HeroCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final onGradient = df.onGradient('hero');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.gradient ?? df.gradientStops('hero'),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: onGradient.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                config.heroEmoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            config.productName,
            style: TextStyle(
              color: onGradient,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            config.trialHeadline,
            style: TextStyle(
              color: onGradient.withValues(alpha: 0.7),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final PaywallConfig config;
  const _PriceCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final accent = config.accentColor ?? df.colors.brand.base;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: df.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.priceLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: df.colors.brand.deep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.afterTrialLabel,
                  style: TextStyle(fontSize: 12, color: df.colors.textTertiary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              config.cancellationNote,
              style: TextStyle(
                fontSize: 11,
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final PaywallConfig config;
  const _FeatureCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final accent = config.accentColor ?? df.colors.brand.base;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: df.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.fill(config.featuresHeadline),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: df.colors.brand.deep,
            ),
          ),
          const SizedBox(height: 12),
          ...config.features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 14,
                        color: df.colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            config.credibilityText,
            style: TextStyle(
              fontSize: 11,
              color: df.colors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
