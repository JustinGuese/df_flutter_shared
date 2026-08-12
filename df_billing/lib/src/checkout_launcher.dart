import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Why a checkout attempt did not open a payment page.
enum DfCheckoutFailure {
  /// The user is anonymous. Without a stable user id the webhook cannot attach
  /// the purchase to anyone, so the app must register them first.
  authRequired,

  /// No live or test URL is configured for that key.
  notConfigured,

  /// The platform refused to open the URL.
  launchFailed,
}

/// Outcome of [DfCheckout.open]. Success is [failure] being null.
@immutable
class DfCheckoutResult {
  const DfCheckoutResult.success() : failure = null, url = null;
  const DfCheckoutResult.failed(this.failure, {this.url});

  final DfCheckoutFailure? failure;
  final String? url;

  bool get isSuccess => failure == null;
}

/// Opens hosted payment pages.
///
/// Pure URL construction plus a launch — no Stripe SDK, and no UI. Callers
/// decide what a failure looks like, which keeps copy and navigation in the
/// app where they belong.
abstract final class DfCheckout {
  /// Opens the payment page for [url].
  ///
  /// [userId] is required: it is encoded into `client_reference_id` as
  /// `<userId>|<productSlug>` so the backend webhook can attribute the payment.
  /// Passing null returns [DfCheckoutFailure.authRequired] rather than opening
  /// an unattributable checkout — a payment the backend cannot match to a user
  /// is worse than no payment, because it takes the money and grants nothing.
  static Future<DfCheckoutResult> open({
    required String? url,
    required String? userId,
    String? productSlug,
    String? email,
    Map<String, String> extraParams = const <String, String>{},
  }) async {
    if (url == null || url.isEmpty) {
      return const DfCheckoutResult.failed(DfCheckoutFailure.notConfigured);
    }
    if (userId == null || userId.isEmpty) {
      return const DfCheckoutResult.failed(DfCheckoutFailure.authRequired);
    }

    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters)
      ..addAll(extraParams)
      ..['client_reference_id'] = productSlug == null
          ? userId
          : '$userId|$productSlug';
    if (email != null && email.isNotEmpty) {
      params['prefilled_email'] = email;
    }

    final target = uri.replace(queryParameters: params);
    try {
      final ok = await launchUrl(
        target,
        // External, not in-app: Stripe Checkout needs its own browser context
        // for 3-D Secure and saved payment methods.
        mode: LaunchMode.externalApplication,
      );
      return ok
          ? const DfCheckoutResult.success()
          : DfCheckoutResult.failed(
              DfCheckoutFailure.launchFailed,
              url: target.toString(),
            );
    } catch (_) {
      return DfCheckoutResult.failed(
        DfCheckoutFailure.launchFailed,
        url: target.toString(),
      );
    }
  }

  /// Opens the billing portal, where users manage or cancel their subscription.
  ///
  /// No `client_reference_id` — the portal identifies the customer by their
  /// login, so it only needs the URL.
  static Future<DfCheckoutResult> openPortal(String? url) async {
    if (url == null || url.isEmpty) {
      return const DfCheckoutResult.failed(DfCheckoutFailure.notConfigured);
    }
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      return ok
          ? const DfCheckoutResult.success()
          : DfCheckoutResult.failed(DfCheckoutFailure.launchFailed, url: url);
    } catch (_) {
      return DfCheckoutResult.failed(DfCheckoutFailure.launchFailed, url: url);
    }
  }

  /// The URL [open] would launch, without launching it. For tests and logging.
  @visibleForTesting
  static Uri buildUrl({
    required String url,
    required String userId,
    String? productSlug,
    String? email,
    Map<String, String> extraParams = const <String, String>{},
  }) {
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters)
      ..addAll(extraParams)
      ..['client_reference_id'] = productSlug == null
          ? userId
          : '$userId|$productSlug';
    if (email != null && email.isNotEmpty) {
      params['prefilled_email'] = email;
    }
    return uri.replace(queryParameters: params);
  }
}
