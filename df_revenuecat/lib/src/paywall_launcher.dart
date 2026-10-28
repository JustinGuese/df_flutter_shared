import 'dart:async';

import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_theme/df_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'revenuecat_service.dart';
import 'revenuecat_strings.dart';

/// Callback invoked when a user successfully purchases or restores an entitlement.
typedef DfPurchaseCallback = FutureOr<void> Function(BuildContext context);

/// Launcher coordinating paywall presentation, web fallback, analytics,
/// and exit offers.
abstract final class DfPaywallLauncher {
  /// Opens a paywall for [placement].
  ///
  /// - Tracks `paywall_opened` and `paywall_result` via [DfAnalyticsCore].
  /// - On Web, tracks `paywall_result` ('web_info') and delegates to [onWeb] or
  ///   shows [DfWebSubscriptionDialog].
  /// - On cancel, checks if [placement] is in `config.exitOfferAfter` and triggers
  ///   the exit offer at most once per install.
  /// - On successful purchase or restore, invokes [onPurchased].
  static Future<DfPaywallResult> show(
    BuildContext context, {
    required String placement,
    bool force = false,
    DfPaywallPresenter? presenter,
    SharedPreferences? prefs,
    FutureOr<void> Function(BuildContext context)? onWeb,
    DfPurchaseCallback? onPurchased,
    DfRevenueCatStrings strings = const DfRevenueCatStrings(),
  }) async {
    DfAnalyticsCore.track('paywall_opened', {'placement': placement});

    if (kIsWeb) {
      DfAnalyticsCore.track('paywall_result', {
        'placement': placement,
        'result': 'web_info',
      });
      if (context.mounted) {
        if (onWeb != null) {
          await onWeb(context);
        } else {
          await showDialog<void>(
            context: context,
            builder: (ctx) => DfWebSubscriptionDialog(strings: strings),
          );
        }
      }
      return DfPaywallResult.notPresented;
    }

    try {
      final activePresenter = presenter ?? DfRevenueCat.presenter;
      final result = await activePresenter.presentPaywall(
        placement: placement,
        force: force,
      );
      DfAnalyticsCore.track('paywall_result', {
        'placement': placement,
        'result': result.name,
      });

      if (result.isSuccess && context.mounted) {
        await onPurchased?.call(context);
        return result;
      } else if (result == DfPaywallResult.cancelled) {
        if (!context.mounted) return result;
        return await _maybeExitOffer(
          context,
          placement: placement,
          dismissed: result,
          presenter: activePresenter,
          prefs: prefs,
          onPurchased: onPurchased,
        );
      }
      return result;
    } catch (e) {
      debugPrint('Error presenting paywall for placement $placement: $e');
      DfAnalyticsCore.track('paywall_result', {
        'placement': placement,
        'result': 'error',
      });
      return DfPaywallResult.error;
    }
  }

  static Future<DfPaywallResult> _maybeExitOffer(
    BuildContext context, {
    required String placement,
    required DfPaywallResult dismissed,
    required DfPaywallPresenter presenter,
    SharedPreferences? prefs,
    DfPurchaseCallback? onPurchased,
  }) async {
    final config = DfRevenueCat.config;
    if (!config.exitOfferAfter.contains(placement)) {
      return dismissed;
    }
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      if (p.getBool(config.exitOfferShownKey) ?? false) {
        return dismissed;
      }
      final exitResult = await presenter.presentExitOffer();
      if (exitResult == DfPaywallResult.notPresented) {
        return dismissed;
      }
      await p.setBool(config.exitOfferShownKey, true);
      DfAnalyticsCore.track('paywall_result', {
        'placement': config.exitOfferPlacement,
        'result': exitResult.name,
      });
      if (exitResult.isSuccess && context.mounted) {
        await onPurchased?.call(context);
      }
      return exitResult;
    } catch (e) {
      debugPrint('Error presenting exit offer: $e');
      return dismissed;
    }
  }
}

/// Fallback dialog shown when paywall is triggered on Web platforms.
class DfWebSubscriptionDialog extends StatelessWidget {
  const DfWebSubscriptionDialog({
    super.key,
    this.strings = const DfRevenueCatStrings(),
  });

  /// Strings used for title, body, and button copy.
  final DfRevenueCatStrings strings;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: df.shape.radiusLg),
      title: Text(
        strings.webDialogTitle,
        style: textTheme.titleMedium?.copyWith(color: df.colors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.webDialogDescription,
            style: textTheme.bodyMedium?.copyWith(color: df.colors.textPrimary),
          ),
          SizedBox(height: df.spacing.md),
          Text(
            strings.webDialogInstruction,
            style: textTheme.bodySmall?.copyWith(
              color: df.colors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.webDialogButtonLabel),
        ),
      ],
    );
  }
}
