import 'package:df_revenuecat/df_revenuecat.dart' hide DfPaywallPresenter;
import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contracts.dart';

/// Centralized strings used across the funnel widgets.
///
/// Prevents hard-coded copy while allowing full customization per app.
@immutable
class DfFunnelStrings {
  const DfFunnelStrings({
    this.proPillLabel = 'Try Pro free',
    this.heroEyebrow = 'PRO',
    this.heroTitle = 'Brief Tech News Pro',
    this.heroSubtitle = 'Zero ads. An AI analyst for every story.',
    this.heroCta = 'Try Pro 14 Days Free',
    this.upsellEyebrow = 'PRO',
    this.upsellTitle = 'Read more, see fewer ads.',
    this.upsellCta = 'Upgrade to Pro',
    this.upsellLater = 'Maybe later',
    this.lockedTitle = 'Unlock with Pro',
    this.lockedSubtitle = 'Tap to upgrade to premium',
    this.lockedAction = 'Upgrade',
    this.perkZeroAdsTitle = 'Zero ads',
    this.perkZeroAdsBody = 'No banners, no sponsored cards.',
    this.perkAiAnalystTitle = 'AI News Analyst',
    this.perkAiAnalystBody = 'Chat about the news with an expert.',
    this.perkAskAnyStoryTitle = 'Ask about any story',
    this.perkAskAnyStoryBody = 'One tap from the article to the answer.',
  });

  final String proPillLabel;
  final String heroEyebrow;
  final String heroTitle;
  final String heroSubtitle;
  final String heroCta;
  final String upsellEyebrow;
  final String upsellTitle;
  final String upsellCta;
  final String upsellLater;
  final String lockedTitle;
  final String lockedSubtitle;
  final String lockedAction;
  final String perkZeroAdsTitle;
  final String perkZeroAdsBody;
  final String perkAiAnalystTitle;
  final String perkAiAnalystBody;
  final String perkAskAnyStoryTitle;
  final String perkAskAnyStoryBody;
}

/// Persistent cooldown gate backed by [SharedPreferences].
///
/// Records an ISO 8601 timestamp at [key]. [isReady] returns true if the key
/// has never been set or if at least [duration] has passed since the last [mark].
class DfCooldown {
  const DfCooldown({required this.key, required this.duration});

  final String key;
  final Duration duration;

  Future<bool> isReady({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().difference(last) >= duration;
  }

  Future<void> mark({SharedPreferences? prefs, DateTime? now}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final timestamp = (now ?? DateTime.now()).toIso8601String();
    await p.setString(key, timestamp);
  }

  Future<void> reset({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.remove(key);
  }

  Future<DateTime?> lastMarked({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

/// Representation of a perk listed inside [DfUpsellSheet].
@immutable
class DfPerkItem {
  const DfPerkItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

/// Labelled upgrade entry point for the app bar or headers (free users).
class DfProPill extends StatelessWidget {
  const DfProPill({
    super.key,
    this.onTap,
    this.placement = 'app_bar_pill',
    this.paywallPresenter,
    this.strings = const DfFunnelStrings(),
    this.icon = Icons.workspace_premium,
  });

  final VoidCallback? onTap;
  final String placement;
  final DfPaywallPresenter? paywallPresenter;
  final DfFunnelStrings strings;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: df.spacing.sm),
      child: Material(
        color: df.colors.brand.base,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap ??
              () {
                if (paywallPresenter != null) {
                  paywallPresenter!(context, placement: placement);
                } else {
                  DfPaywallLauncher.show(context, placement: placement);
                }
              },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: df.spacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: df.colors.textOnBrand),
                SizedBox(width: df.spacing.xs),
                Text(
                  strings.proPillLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: df.colors.textOnBrand,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width upgrade card; dominant action on settings or profile screens.
class DfProHeroCard extends ConsumerWidget {
  const DfProHeroCard({
    super.key,
    this.onTap,
    this.placement = 'settings_hero',
    this.paywallPresenter,
    this.strings = const DfFunnelStrings(),
    this.title,
    this.eyebrow,
    this.subtitle,
    this.ctaLabel,
  });

  final VoidCallback? onTap;
  final String placement;
  final DfPaywallPresenter? paywallPresenter;
  final DfFunnelStrings strings;
  final String? title;
  final String? eyebrow;
  final String? subtitle;
  final String? ctaLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trial = ref.watch(dfTrialOfferProvider).value;
    final df = context.df;
    final text = Theme.of(context).textTheme;
    final on = df.onGradient('brand');

    return Container(
      padding: EdgeInsets.all(df.spacing.mdPlus),
      decoration: BoxDecoration(
        gradient: df.gradient('brand'),
        borderRadius: df.shape.radiusXl,
        boxShadow: df.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow ?? strings.heroEyebrow,
            style: df.eyebrow.copyWith(color: on.withValues(alpha: 0.8)),
          ),
          SizedBox(height: df.spacing.sm),
          Text(
            title ?? strings.heroTitle,
            style: text.titleLarge?.copyWith(color: on),
          ),
          if (subtitle != null || strings.heroSubtitle.isNotEmpty) ...[
            SizedBox(height: df.spacing.xs),
            Text(
              subtitle ?? strings.heroSubtitle,
              style:
                  text.bodyMedium?.copyWith(color: on.withValues(alpha: 0.9)),
            ),
          ],
          SizedBox(height: df.spacing.md),
          FilledButton(
            onPressed: onTap ??
                () {
                  if (paywallPresenter != null) {
                    paywallPresenter!(context, placement: placement);
                  } else {
                    DfPaywallLauncher.show(context, placement: placement);
                  }
                },
            style: FilledButton.styleFrom(
              backgroundColor: on,
              foregroundColor: df.colors.brand.deep,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: df.shape.radiusButton,
              ),
            ),
            child: Text(ctaLabel ?? trial?.startLabel ?? strings.heroCta),
          ),
        ],
      ),
    );
  }
}

/// Contextual "Try Pro free" bottom sheet with configurable cooldown.
class DfUpsellSheet extends ConsumerWidget {
  const DfUpsellSheet({
    super.key,
    this.placement = 'feed_sheet',
    this.paywallPresenter,
    this.strings = const DfFunnelStrings(),
    this.perks,
    this.onCta,
  });

  final String placement;
  final DfPaywallPresenter? paywallPresenter;
  final DfFunnelStrings strings;
  final List<DfPerkItem>? perks;
  final VoidCallback? onCta;

  static const String defaultCooldownKey = 'df_upsell_sheet_cooldown';
  static const Duration defaultCooldownDuration = Duration(hours: 24);

  /// Shows the upsell bottom sheet if [cooldown] is ready.
  ///
  /// Returns `true` if shown, or `false` if blocked by cooldown.
  static Future<bool> maybeShow(
    BuildContext context, {
    DfCooldown cooldown = const DfCooldown(
      key: defaultCooldownKey,
      duration: defaultCooldownDuration,
    ),
    SharedPreferences? prefs,
    String placement = 'feed_sheet',
    DfPaywallPresenter? paywallPresenter,
    DfFunnelStrings strings = const DfFunnelStrings(),
    List<DfPerkItem>? perks,
    VoidCallback? onCta,
  }) async {
    final ready = await cooldown.isReady(prefs: prefs);
    if (!ready) return false;
    await cooldown.mark(prefs: prefs);
    if (!context.mounted) return false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DfUpsellSheet(
        placement: placement,
        paywallPresenter: paywallPresenter,
        strings: strings,
        perks: perks,
        onCta: onCta,
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trial = ref.watch(dfTrialOfferProvider).value;
    final df = context.df;
    final text = Theme.of(context).textTheme;

    final resolvedPerks = perks ?? [
      DfPerkItem(
        icon: Icons.block_rounded,
        title: strings.perkZeroAdsTitle,
        body: strings.perkZeroAdsBody,
      ),
      DfPerkItem(
        icon: Icons.auto_awesome,
        title: strings.perkAiAnalystTitle,
        body: strings.perkAiAnalystBody,
      ),
      DfPerkItem(
        icon: Icons.forum_outlined,
        title: strings.perkAskAnyStoryTitle,
        body: strings.perkAskAnyStoryBody,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(df.spacing.lg),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: df.shape.radiusSheet,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.upsellEyebrow, style: df.eyebrow),
            SizedBox(height: df.spacing.sm),
            Text(
              strings.upsellTitle,
              style: text.headlineSmall?.copyWith(color: df.colors.textPrimary),
            ),
            SizedBox(height: df.spacing.md),
            for (final perk in resolvedPerks)
              Padding(
                padding: EdgeInsets.only(bottom: df.spacing.sm),
                child: Row(
                  children: [
                    Icon(perk.icon, color: df.colors.brand.base, size: 22),
                    SizedBox(width: df.spacing.md),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${perk.title}  ',
                              style: text.titleSmall?.copyWith(
                                color: df.colors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: perk.body,
                              style: text.bodySmall?.copyWith(
                                color: df.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: df.spacing.md),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCta != null) {
                  onCta!();
                } else if (paywallPresenter != null) {
                  paywallPresenter!(context, placement: placement);
                } else {
                  DfPaywallLauncher.show(context, placement: placement);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: df.colors.brand.base,
                foregroundColor: df.colors.textOnBrand,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: df.shape.radiusButton,
                ),
              ),
              child: Text(trial?.startLabel ?? strings.upsellCta),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  strings.upsellLater,
                  style: TextStyle(color: df.colors.textTertiary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
