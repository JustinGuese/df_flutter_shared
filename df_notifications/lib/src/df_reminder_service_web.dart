import 'dart:async';
// JSPromise.toDart / JSString.toDart live here — the `web` package alone
// doesn't bring them into scope.
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'df_reminder.dart';
import 'df_reminder_schedule.dart';
import 'df_reminder_service.dart';

DfReminderService createReminderService() => WebReminderService();

/// Web implementation using the browser Notification API.
///
/// A browser can only fire a notification while the tab / installed PWA is
/// running, so scheduling is done with in-session [Timer]s. Apps should pair
/// this with an in-app "reminders due" surface for anything missed while the
/// tab was closed.
///
/// Tap-to-payload routing (reliable on native via
/// `getNotificationAppLaunchDetails`) has no equivalent here: a browser
/// notification click does not hand back a payload the way a cold app launch
/// does, so [consumePendingPayload] always returns `null` on web.
class WebReminderService implements DfReminderService {
  final Map<int, Timer> _timers = {};

  @override
  Future<void> init() async {
    // Nothing to initialise on web.
  }

  @override
  String? consumePendingPayload() => null;

  @override
  Future<bool> requestPermission() async {
    if (web.Notification.permission == 'granted') return true;
    if (web.Notification.permission == 'denied') return false;
    final result = await web.Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  @override
  Future<void> schedule(DfReminder reminder) async {
    _timers.remove(reminder.id)?.cancel();

    final fireAt = DfReminderSchedule.nextOccurrence(reminder, DateTime.now());
    if (fireAt == null) return;

    final delay = fireAt.difference(DateTime.now());
    // Timer caps at ~24.8 days (int32 ms). A reminder further out than that
    // is simply not armed here — the app is expected to re-run `schedule` on
    // its own cadence (e.g. every resume), which is also what re-arms a
    // repeating reminder's *next* occurrence once this one has fired.
    if (delay.isNegative || delay.inMilliseconds > 0x7FFFFFFF) return;

    _timers[reminder.id] = Timer(delay, () {
      _timers.remove(reminder.id);
      _show(reminder);
      if (reminder.repeat != DfReminderRepeat.none) {
        schedule(reminder.copyWith(scheduledAt: fireAt));
      }
    });
  }

  void _show(DfReminder reminder) {
    if (web.Notification.permission != 'granted') return;
    web.Notification(
      reminder.title,
      web.NotificationOptions(
        body: reminder.body,
        tag: 'df-reminder-${reminder.id}',
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    _timers.remove(id)?.cancel();
  }

  @override
  Future<void> cancelMany(Iterable<int> ids) async {
    for (final id in ids) {
      _timers.remove(id)?.cancel();
    }
  }
}
