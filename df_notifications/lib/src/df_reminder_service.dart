import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'df_reminder.dart';
// Platform selection: flutter_local_notifications on native, the browser
// Notification API on web. Guarded on dart.library.js_interop rather than
// dart.library.html so the web implementation is also selected under Wasm,
// which has no `dart:html`.
import 'df_reminder_service_native.dart'
    if (dart.library.js_interop) 'df_reminder_service_web.dart';

/// Platform-agnostic local reminder scheduler.
///
/// Delivery is purely on-device — no server, no push. On native (iOS/Android)
/// reminders fire even when the app is closed. On web a reminder only fires
/// while the tab / installed PWA is open; apps should pair this with an
/// in-app "you have a reminder due" surface as the safety net for missed ones.
abstract class DfReminderService {
  /// One-time setup (timezone db + tap-routing wiring on native, no-op on
  /// web). Every other method calls this internally, so most apps never need
  /// to call it directly — call it explicitly only to receive taps that
  /// happen before the first schedule/cancel call.
  Future<void> init();

  /// Ask the OS / browser for notification permission. Returns whether
  /// granted. Prefer routing this through `ensureDfNotificationPermission` so
  /// the user sees an in-app soft-ask first — the OS prompt can only be shown
  /// once per install on most platforms.
  Future<bool> requestPermission();

  /// (Re)schedules [reminder]. A past one-shot ([DfReminderRepeat.none]) is
  /// silently ignored; a past repeating reminder is rolled forward to its
  /// next occurrence. Scheduling with an id that already has a pending
  /// notification replaces it.
  Future<void> schedule(DfReminder reminder);

  /// Cancels a single scheduled reminder by id. A no-op if nothing is
  /// scheduled under that id.
  Future<void> cancel(int id);

  /// Cancels several reminders at once — the primitive an app's own "sync all
  /// reminders for my current data" reconciliation loop is built from.
  Future<void> cancelMany(Iterable<int> ids);

  /// Returns (and clears) the payload of the notification that either
  /// launched the app cold or was tapped while the app was running. `null`
  /// when there is nothing pending. Call after [init] (e.g. on the first
  /// frame) to route a cold start to the right screen.
  String? consumePendingPayload();

  factory DfReminderService() => createReminderService();
}

/// Riverpod access point, matching the other df_* packages' convention of
/// exposing a `Provider` for their main service.
final dfReminderServiceProvider = Provider<DfReminderService>((ref) {
  return DfReminderService();
});
