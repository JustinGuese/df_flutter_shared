import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subscription_provider.dart';

/// A debug settings tile that lets developers toggle Pro mode simulation
/// (bypassing store/backend checks) when running in debug mode.
class DfDebugProTile extends ConsumerWidget {
  const DfDebugProTile({
    super.key,
    this.title = 'Simulate Pro Mode',
    this.subtitle = 'Bypass store/backend entitlement checks for local testing',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();
    final override = ref.watch(dfDebugPremiumOverrideProvider) ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          secondary: const Icon(Icons.bug_report, color: Colors.amber),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          value: override,
          onChanged: (val) {
            ref.read(dfDebugPremiumOverrideProvider.notifier).set(val ? true : null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  val
                      ? 'Pro mode simulation enabled 🎉'
                      : 'Pro mode simulation disabled',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Helper for simulating Pro purchases in debug mode when products are not published.
abstract final class DfDebugBilling {
  /// Shows a debug simulator dialog when a paywall fails or products are not found.
  static Future<bool> showSimulatorDialog(
    BuildContext context, {
    String title = '🧪 Test Paywall (Debug)',
    String message = 'Products are not published in store yet ("product not found").\n\nWould you like to simulate a successful Pro purchase?',
    String confirmButtonText = 'Simulate Pro Purchase 🎉',
  }) async {
    if (!kDebugMode) return false;
    final simulate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );

    if (simulate == true && context.mounted) {
      ProviderScope.containerOf(context, listen: false)
          .read(dfDebugPremiumOverrideProvider.notifier)
          .set(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pro mode simulated successfully! 🎉')),
      );
      return true;
    }
    return false;
  }
}
