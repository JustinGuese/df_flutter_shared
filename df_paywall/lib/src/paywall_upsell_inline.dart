import 'package:flutter/material.dart';
import 'paywall_config.dart';

/// Inline paywall widget intended for use inside a step-based content viewer
/// (e.g. a course screen). Renders a preview of the locked step and a CTA
/// to upgrade, without navigating away from the current screen.
///
/// Pair this with [LearningCourseScreen]'s `stepGateBuilder` from `df_onboarding`.
///
/// Example:
/// ```dart
/// LearningCourseScreen(
///   course: course,
///   stepGateBuilder: (stepIndex) {
///     if (stepIndex == 0 || isPremium) return null;
///     return PaywallUpsellInline(
///       stepTitle: course.steps[stepIndex].title,
///       stepEmoji: course.steps[stepIndex].emoji,
///       config: myConfig,
///       onCta: () => subscriptionService.startCheckout(),
///     );
///   },
/// )
/// ```
class PaywallUpsellInline extends StatefulWidget {
  /// Title of the locked step — shown so users know what they'd get.
  final String stepTitle;

  /// Emoji of the locked step.
  final String stepEmoji;

  /// Paywall copy and visual config.
  final PaywallConfig config;

  /// Called when the user taps the CTA. Typically opens a checkout URL.
  /// Return a [Future] so the button can show a loading state.
  final Future<void> Function() onCta;

  const PaywallUpsellInline({
    super.key,
    required this.stepTitle,
    required this.stepEmoji,
    required this.config,
    required this.onCta,
  });

  @override
  State<PaywallUpsellInline> createState() => _PaywallUpsellInlineState();
}

class _PaywallUpsellInlineState extends State<PaywallUpsellInline> {
  bool _loading = false;

  Future<void> _handleCta() async {
    setState(() => _loading = true);
    try {
      await widget.onCta();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Fehler beim Öffnen der Zahlungsseite. Bitte versuchen Sie es erneut.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Text(widget.stepEmoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                Text(
                  widget.stepTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C445A),
                  ),
                ),
                const SizedBox(height: 8),
                // Placeholder bars suggesting locked content
                ...List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Lock label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cfg.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_rounded, size: 20, color: cfg.accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                '${cfg.productName} erforderlich',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0C445A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${cfg.trialHeadline} · ${cfg.priceLabel} · ${cfg.cancellationNote}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          // Compact feature rows
          ...cfg.features.take(3).map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 15, color: cfg.accentColor),
                      const SizedBox(width: 8),
                      Text(f,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 24),
          // CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleCta,
              style: ElevatedButton.styleFrom(
                backgroundColor: cfg.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      '${cfg.productName} — ${cfg.ctaText}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
