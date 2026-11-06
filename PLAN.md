# PLAN.md - round 2: move notification scheduling, subscription settings, generic widgets into shared packages
Reference implementations live in the app (read only, do NOT edit): /home/jguese/code/flutter-bigtechnews-swiper-app/lib/providers/notification_scheduler_provider.dart, lib/screens/settings_screen.dart, lib/widgets/feed_filter_bar.dart (or lib/screens/home/feed_filter_bar.dart), lib/screens/chat/chat_typing_indicator.dart (find with `find`).
Rules: no hard-coded copy or colours (strings via a *Strings class with English defaults, colours via df_theme `context.df`), additive only, reuse existing helpers (DfReminderService, DfReminder, DfNotificationIds, DfReminderPreferences, DfCooldown). Tests: 2-3 flutter tests per step, run only those.

## Batch 1 (parallel; export lines in package barrel files are added by the orchestrator, do not edit barrels)
### N1 - df_notifications controllers
Files: df_notifications/lib/src/df_daily_reminder.dart, df_notifications/lib/src/df_trial_ending_reminder.dart, df_notifications/test/df_daily_reminder_test.dart, df_notifications/test/df_trial_ending_reminder_test.dart
- DfDailyReminder: configurable id/hour/title/body/payload, ensure() idempotent (next occurrence, daily repeat), cancel(), restoreIfEnabled(prefsKey).
- DfTrialEndingReminder.schedule(trialEnd, ...): leadTime default 2 days, only if notifications enabled pref true, skips if the fire time is < 1h away.
Accept: tests for next-occurrence rollover, disabled-pref no-op, too-late no-op, cancel.

### N2 - df_notifications toggle tile
Files: df_notifications/lib/src/df_notification_toggle_tile.dart, df_notifications/test/df_notification_toggle_tile_test.dart
- DfNotificationToggleTile: loads pref, shows switch/spinner, on enable runs a supplied `requestPermission` callback then `onEnabled`, on disable `onDisabled`; snackbar texts from DfNotificationStrings (add fields additively in df_notification_strings.dart - listed file allowed).
Files add: df_notifications/lib/src/df_notification_strings.dart
Accept: tests for granted -> persisted true + onEnabled; denied -> stays off + message; disable path.

### N3 - df_funnel subscription settings
Files: df_funnel/lib/src/subscription_settings_section.dart, df_funnel/test/subscription_settings_section_test.dart
- DfSubscriptionSettingsSection: manage-subscription tile (store link/fallback snackbar), Customer Center tile, Restore Purchases tile, web fallback message, error snackbars; injectable callbacks for tests; strings class.
Accept: tests for restore success/error, web message, customer-center error.

### N4 - df_ui_widgets generic widgets
Files: df_ui_widgets/lib/src/filter_chip_bar.dart, df_ui_widgets/lib/src/typing_indicator.dart, df_ui_widgets/test/filter_chip_bar_test.dart, df_ui_widgets/test/typing_indicator_test.dart
- DfFilterChipBar(items, selected, onSelected) and DfTypingIndicator generalised from the app versions.
Accept: selection callback test; indicator animates without throwing and disposes cleanly.

## Batch 2 (app, after the shared repo is pushed) - defined after Batch 1 merges
