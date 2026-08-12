import 'package:flutter/foundation.dart';

/// Resolves hosted payment links, picking the test or live set.
///
/// DF apps bill through Stripe Payment Links plus a backend webhook, so the
/// client's whole job is choosing the right URL and opening it.
///
/// Which set is used, in order:
///  1. `--dart-define=USE_BILLING=test` (or `live`) — explicit and wins.
///  2. [isTestEnvironment], when supplied — e.g. a staging host check.
///  3. Debug builds default to test; release builds default to live.
///
/// That last rule is the important one: an earlier hand-rolled version keyed
/// only off the hostname, so a debug build on localhost silently pointed at
/// **live** Stripe.
@immutable
class DfCheckoutLinks {
  const DfCheckoutLinks({
    required this.live,
    required this.test,
    this.isTestEnvironment,
  });

  /// Live URLs by key, e.g. `{'subscription': 'https://buy.stripe.com/…'}`.
  final Map<String, String> live;

  /// Test-mode URLs, same keys.
  final Map<String, String> test;

  /// Optional extra condition forcing test mode — typically a staging-host
  /// check. Ignored when `USE_BILLING` is set.
  final bool Function()? isTestEnvironment;

  static const _override = String.fromEnvironment('USE_BILLING');

  bool get useTest {
    if (_override == 'test') return true;
    if (_override == 'live') return false;
    if (isTestEnvironment?.call() ?? false) return true;
    return kDebugMode;
  }

  /// The URL for [key], or null when it is not configured.
  ///
  /// Falls back to the test URL when a live URL is missing, so a half-configured
  /// funnel opens a working test page instead of a blank Stripe error. Returns
  /// null only when neither is set — callers should hide the entry point rather
  /// than open nothing.
  String? url(String key) {
    final preferred = useTest ? test[key] : live[key];
    if (preferred != null && preferred.isNotEmpty) return preferred;
    final fallback = test[key];
    if (fallback != null && fallback.isNotEmpty) {
      assert(() {
        debugPrint(
          'df_billing: no ${useTest ? 'test' : 'live'} URL for "$key"; '
          'falling back to the test link.',
        );
        return true;
      }());
      return fallback;
    }
    return null;
  }

  /// Whether [key] can be opened at all.
  bool has(String key) => url(key) != null;
}
