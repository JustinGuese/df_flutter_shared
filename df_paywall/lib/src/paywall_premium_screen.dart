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
          const SnackBar(
              content: Text('Fehler beim Öffnen der Zahlungsseite.')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Öffnen des Kundenportals.')),
        );
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
                backgroundColor: cfg.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loadingUpgrade
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      cfg.ctaText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumView(PaywallSubscriptionInfo sub) {
    final cfg = widget.config;
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
                colors: cfg.gradient,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('✅', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  'Sie sind ${cfg.productName} Mitglied',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (sub.isTrialing && daysLeft != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Noch $daysLeft Tage kostenlos',
                      style: const TextStyle(
                        color: Color(0xFFFFB800),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: cfg.accentColor),
                  const SizedBox(width: 10),
                  Text(
                    sub.isTrialing && sub.trialEnd != null
                        ? 'Testphase endet am ${_fmtDate(sub.trialEnd!)}'
                        : 'Nächste Abrechnung: ${_fmtDate(sub.currentPeriodEnd!)}',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF334155)),
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
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.open_in_new, size: 18),
                label: const Text('Abo & Zahlung verwalten'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cfg.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Kündigung, Zahlungsmethode und Rechnungen im Kundenportal',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.gradient,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(config.heroEmoji,
                  style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            config.productName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            config.trialHeadline,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.priceLabel,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C445A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Nach der kostenlosen Testphase',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: config.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              config.cancellationNote,
              style: TextStyle(
                fontSize: 11,
                color: config.accentColor,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enthalten in ${config.productName}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF0C445A),
            ),
          ),
          const SizedBox(height: 12),
          ...config.features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: config.accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF334155),
                          height: 1.4),
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
                fontSize: 11, color: Colors.grey[400], height: 1.4),
          ),
        ],
      ),
    );
  }
}
