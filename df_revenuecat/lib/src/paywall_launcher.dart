import 'dart:async';

import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_theme/df_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
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
  /// - Tracks [DfEvents.paywallOpened] and [DfEvents.paywallResult] via [DfAnalyticsCore].
  /// - On Web, tracks [DfEvents.paywallResult] ('web_info') and delegates to [onWeb] or
  ///   shows [DfWebSubscriptionDialog].
  /// - On cancel, checks if [placement] is in `config.exitOfferAfter` and triggers
  ///   the exit offer at most once per install.
  /// - On successful purchase or restore, invokes [onPurchased].
  /// - Before presenting, silently tries [restore] (unless [restoreFirst] is
  ///   false): a reinstalled/new-device user whose store account already owns
  ///   the subscription must never see the paywall, and buying again would
  ///   fail with "product already active". On success the result is
  ///   [DfPaywallResult.restored] and no paywall is shown.
  /// - If the paywall closes with `cancelled` or `error`, silently tries
  ///   [restore] (default [DfRevenueCat.restore]) first: the store account may
  ///   already own the subscription (reinstall, new device, store
  ///   `ITEM_ALREADY_OWNED`), in which case the result becomes
  ///   [DfPaywallResult.restored].
  static Future<DfPaywallResult> show(
    BuildContext context, {
    required String placement,
    bool force = false,
    DfPaywallPresenter? presenter,
    SharedPreferences? prefs,
    FutureOr<void> Function(BuildContext context)? onWeb,
    DfPurchaseCallback? onPurchased,
    DfRevenueCatStrings strings = const DfRevenueCatStrings(),
    Future<bool> Function()? restore,
    bool restoreFirst = true,
  }) async {
    DfAnalyticsCore.track(DfEvents.paywallOpened, {'placement': placement});

    if (kIsWeb) {
      DfAnalyticsCore.track(DfEvents.paywallResult, {
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
      if (restoreFirst && await _silentRestore(restore)) {
        DfAnalyticsCore.track(DfEvents.paywallResult, {
          'placement': placement,
          'result': DfPaywallResult.restored.name,
        });
        if (context.mounted) await onPurchased?.call(context);
        return DfPaywallResult.restored;
      }
      if (!context.mounted) return DfPaywallResult.notPresented;
      final activePresenter = presenter ?? DfRevenueCat.presenter;
      final result = await activePresenter.presentPaywall(
        placement: placement,
        force: force,
      );
      DfAnalyticsCore.track(DfEvents.paywallResult, {
        'placement': placement,
        'result': result.name,
      });

      if (result.isSuccess && context.mounted) {
        await onPurchased?.call(context);
        return result;
      }
      if ((result == DfPaywallResult.cancelled ||
              result == DfPaywallResult.error) &&
          await _silentRestore(restore)) {
        DfAnalyticsCore.track(DfEvents.paywallResult, {
          'placement': placement,
          'result': DfPaywallResult.restored.name,
        });
        if (context.mounted) await onPurchased?.call(context);
        return DfPaywallResult.restored;
      }
      if (result == DfPaywallResult.cancelled) {
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
      DfAnalyticsCore.track(DfEvents.paywallResult, {
        'placement': placement,
        'result': 'error',
      });
      return DfPaywallResult.error;
    }
  }

  static Future<bool> _silentRestore(Future<bool> Function()? restore) async {
    try {
      if (restore == null && !DfRevenueCat.isSdkInitialized) return false;
      return await (restore ?? DfRevenueCat.restore)();
    } catch (e) {
      debugPrint('Silent restore failed: $e');
      return false;
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
      DfAnalyticsCore.track(DfEvents.paywallResult, {
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
