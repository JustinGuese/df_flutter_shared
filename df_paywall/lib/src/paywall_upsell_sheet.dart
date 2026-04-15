import 'package:flutter/material.dart';
import 'paywall_config.dart';

/// Shows a modal bottom sheet with the premium upsell UI.
///
/// [onCta] is called when the user taps the main CTA button. The callback
/// receives an optional [targetCourse] string that the caller passed in —
/// forward it to your checkout session so the user lands on the right screen
/// after subscribing.
///
/// Example:
/// ```dart
/// showPaywallUpsellSheet(
///   context,
///   config: myConfig,
///   targetCourse: 'dekubitusrisiko',
///   onCta: (course) => subscriptionService.startCheckout(targetCourse: course),
/// );
/// ```
void showPaywallUpsellSheet(
  BuildContext context, {
  required PaywallConfig config,
  String? targetCourse,
  required Future<void> Function(String? targetCourse) onCta,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaywallUpsellSheet(
      config: config,
      targetCourse: targetCourse,
      onCta: onCta,
    ),
  );
}

class _PaywallUpsellSheet extends StatefulWidget {
  final PaywallConfig config;
  final String? targetCourse;
  final Future<void> Function(String? targetCourse) onCta;

  const _PaywallUpsellSheet({
    required this.config,
    required this.onCta,
    this.targetCourse,
  });

  @override
  State<_PaywallUpsellSheet> createState() => _PaywallUpsellSheetState();
}

class _PaywallUpsellSheetState extends State<_PaywallUpsellSheet> {
  bool _loading = false;

  Future<void> _handleCta() async {
    setState(() => _loading = true);
    try {
      await widget.onCta(widget.targetCourse);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Öffnen der Zahlungsseite. Bitte versuchen Sie es erneut.'),
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Hero gradient
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(cfg.heroEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cfg.productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cfg.trialHeadline,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            // Price line
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cfg.priceLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0C445A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cfg.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cfg.cancellationNote,
                      style: TextStyle(
                        fontSize: 11,
                        color: cfg.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Feature list
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: cfg.features
                    .map((f) => _FeatureRow(text: f, color: cfg.accentColor))
                    .toList(),
              ),
            ),
            // Credibility
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                cfg.credibilityText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4),
              ),
            ),
            // CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: SizedBox(
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
                          cfg.ctaText,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
            // Neutral dismiss
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                cfg.dismissText,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final Color color;
  const _FeatureRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF334155), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
