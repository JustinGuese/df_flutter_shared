import 'package:df_billing/df_billing.dart';
import 'package:df_revenuecat/df_revenuecat.dart';
import 'package:df_theme/df_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Strings used across [DfSubscriptionSettingsSection].
///
/// Prevents hard-coded copy while allowing customization and localization.
@immutable
class DfSubscriptionSettingsStrings {
  const DfSubscriptionSettingsStrings({
    this.sectionHeader = 'Subscription',
    this.manageSubscriptionTitle = 'Manage Subscription',
    this.manageSubscriptionSubtitle =
        'Change plan, billing, or cancel subscription',
    this.customerCenterTitle = 'Customer Center',
    this.customerCenterSubtitle = 'View subscription status & history',
    this.restorePurchasesTitle = 'Restore Purchases',
    this.restorePurchasesSubtitle =
        'Sync past purchases from App Store / Google Play',
    this.restoreSuccessMessage = 'Purchases successfully restored! 🎉',
    this.restoreNotFoundMessage = 'No active subscription found to restore.',
    this.restoreErrorMessagePrefix = 'Restore error: ',
    this.customerCenterErrorMessagePrefix = 'Customer Center error: ',
    this.storeLinkErrorMessagePrefix = 'Could not open store link: ',
    this.storeLinkFallbackMessage =
        'Please manage subscriptions in your device settings',
    this.webFallbackMessage =
        'Subscription management is not supported on web.',
    this.appleSubscriptionUrl =
        'https://apps.apple.com/account/subscriptions',
    this.googlePlaySubscriptionUrl =
        'https://play.google.com/store/account/subscriptions',
  });

  /// Header text displayed above the section tiles. Set to null to omit.
  final String? sectionHeader;

  /// Title for the manage subscription tile.
  final String manageSubscriptionTitle;

  /// Subtitle for the manage subscription tile.
  final String manageSubscriptionSubtitle;

  /// Title for the RevenueCat Customer Center tile.
  final String customerCenterTitle;

  /// Subtitle for the RevenueCat Customer Center tile.
  final String customerCenterSubtitle;

  /// Title for the restore purchases tile.
  final String restorePurchasesTitle;

  /// Subtitle for the restore purchases tile.
  final String restorePurchasesSubtitle;

  /// Feedback shown when a past subscription is successfully restored.
  final String restoreSuccessMessage;

  /// Feedback shown when restore finishes but no active entitlement was found.
  final String restoreNotFoundMessage;

  /// Prefix before error description when restore fails.
  final String restoreErrorMessagePrefix;

  /// Prefix before error description when Customer Center fails.
  final String customerCenterErrorMessagePrefix;

  /// Prefix before error description when store link cannot be opened.
  final String storeLinkErrorMessagePrefix;

  /// Guidance when the store settings page cannot be launched automatically.
  final String storeLinkFallbackMessage;

  /// Feedback shown when attempting mobile subscription actions in web environments.
  final String webFallbackMessage;

  /// Store URL for Apple subscriptions management.
  final String appleSubscriptionUrl;

  /// Store URL for Google Play subscriptions management.
  final String googlePlaySubscriptionUrl;

  /// Combines [storeLinkFallbackMessage] with the target [url].
  String storeFallback(String url) => '$storeLinkFallbackMessage ($url)';

  /// Formats an error during store link opening.
  String storeLinkError(Object error) => '$storeLinkErrorMessagePrefix$error';

  /// Formats an error during Customer Center launch.
  String customerCenterError(Object error) =>
      '$customerCenterErrorMessagePrefix$error';

  /// Formats an error during purchase restoration.
  String restoreError(Object error) => '$restoreErrorMessagePrefix$error';
}

/// A settings section containing subscription management actions:
/// - Manage subscription (navigates to App Store / Google Play settings)
/// - Customer Center (launches RevenueCat Customer Center)
/// - Restore Purchases (syncs previous purchases on this device)
///
/// Fully configurable with injectable callbacks and strings for easy testing.
class DfSubscriptionSettingsSection extends StatelessWidget {
  const DfSubscriptionSettingsSection({
    super.key,
    this.strings = const DfSubscriptionSettingsStrings(),
    this.isWeb = kIsWeb,
    this.platform,
    this.showManageSubscription = true,
    this.showCustomerCenter = true,
    this.showRestorePurchases = true,
    this.onManageSubscription,
    this.onOpenUrl,
    this.onCustomerCenter,
    this.onPresentCustomerCenter,
    this.onRestorePurchases,
    this.onRestore,
    this.onShowSnackBar,
    this.extraRows = const <Widget>[],
    this.header,
  });

  /// Localized or custom copy for this section.
  final DfSubscriptionSettingsStrings strings;

  /// Whether the widget should behave as running in a web environment.
  final bool isWeb;

  /// Explicit target platform override for testing store link URLs.
  final TargetPlatform? platform;

  /// Whether to render the manage subscription tile.
  final bool showManageSubscription;

  /// Whether to render the Customer Center tile.
  final bool showCustomerCenter;

  /// Whether to render the restore purchases tile.
  final bool showRestorePurchases;

  /// Direct callback when tapping "Manage Subscription".
  /// Overrides store URL opening if provided.
  final Future<void> Function(BuildContext context)? onManageSubscription;

  /// Custom URL launcher for testing or overriding store link navigation.
  /// Return true on success, false if the URL could not be opened.
  final Future<bool> Function(String url)? onOpenUrl;

  /// Seam for launching the Customer Center. Defaults to [DfRevenueCat.presentCustomerCenter].
  final Future<void> Function()? onCustomerCenter;

  /// Alias for [onCustomerCenter].
  final Future<void> Function()? onPresentCustomerCenter;

  /// Seam for restoring purchases. Defaults to [DfRevenueCat.restore].
  final Future<bool> Function()? onRestorePurchases;

  /// Alias for [onRestorePurchases].
  final Future<bool> Function()? onRestore;

  /// Optional listener or interceptor for SnackBar notifications.
  final void Function(BuildContext context, String message, bool isError)?
      onShowSnackBar;

  /// Additional custom rows inserted below the standard tiles.
  final List<Widget> extraRows;

  /// Custom widget replacing the default [strings.sectionHeader] title.
  final Widget? header;

  String _storeUrl(TargetPlatform targetPlatform) {
    return (targetPlatform == TargetPlatform.iOS ||
            targetPlatform == TargetPlatform.macOS)
        ? strings.appleSubscriptionUrl
        : strings.googlePlaySubscriptionUrl;
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (onShowSnackBar != null) {
      onShowSnackBar!(context, message, isError);
      return;
    }
    final df = context.df;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: isError
              ? TextStyle(color: df.colors.textOnBrand)
              : null,
        ),
        backgroundColor: isError ? df.colors.error.base : null,
      ),
    );
  }

  Future<void> _handleManageSubscription(BuildContext context) async {
    if (onManageSubscription != null) {
      await onManageSubscription!(context);
      return;
    }

    if (isWeb) {
      _showMessage(context, strings.webFallbackMessage);
      return;
    }

    final targetPlatform = platform ?? defaultTargetPlatform;
    final url = _storeUrl(targetPlatform);

    try {
      bool opened;
      if (onOpenUrl != null) {
        opened = await onOpenUrl!(url);
      } else {
        final result = await DfCheckout.openPortal(url);
        opened = result.isSuccess;
      }

      if (!opened && context.mounted) {
        _showMessage(context, strings.storeFallback(url));
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, strings.storeLinkError(e), isError: true);
      }
    }
  }

  Future<void> _handleCustomerCenter(BuildContext context) async {
    if (isWeb) {
      _showMessage(context, strings.webFallbackMessage);
      return;
    }

    final handler = onCustomerCenter ?? onPresentCustomerCenter;

    try {
      if (handler != null) {
        await handler();
      } else {
        await DfRevenueCat.presentCustomerCenter();
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, strings.customerCenterError(e), isError: true);
      }
    }
  }

  Future<void> _handleRestorePurchases(BuildContext context) async {
    if (isWeb) {
      _showMessage(context, strings.webFallbackMessage);
      return;
    }

    final handler = onRestorePurchases ?? onRestore;

    try {
      final bool restored;
      if (handler != null) {
        restored = await handler();
      } else {
        restored = await DfRevenueCat.restore();
      }

      if (context.mounted) {
        final message = restored
            ? strings.restoreSuccessMessage
            : strings.restoreNotFoundMessage;
        _showMessage(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, strings.restoreError(e), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    final headerText = strings.sectionHeader;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          header!
        else if (headerText != null && headerText.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: df.spacing.md,
              vertical: df.spacing.xs,
            ),
            child: Text(
              headerText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: df.colors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        if (showManageSubscription)
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: df.colors.info.base,
            ),
            title: Text(strings.manageSubscriptionTitle),
            subtitle: Text(strings.manageSubscriptionSubtitle),
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: df.colors.textSecondary,
            ),
            onTap: () => _handleManageSubscription(context),
          ),
        if (showCustomerCenter)
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: df.colors.brand.base,
            ),
            title: Text(strings.customerCenterTitle),
            subtitle: Text(strings.customerCenterSubtitle),
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: df.colors.textSecondary,
            ),
            onTap: () => _handleCustomerCenter(context),
          ),
        if (showRestorePurchases)
          ListTile(
            leading: Icon(
              Icons.restore,
              color: df.colors.accent.base,
            ),
            title: Text(strings.restorePurchasesTitle),
            subtitle: Text(strings.restorePurchasesSubtitle),
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: df.colors.textSecondary,
            ),
            onTap: () => _handleRestorePurchases(context),
          ),
        ...extraRows,
      ],
    );
  }
}
