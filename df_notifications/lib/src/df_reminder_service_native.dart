import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'df_reminder.dart';
import 'df_reminder_schedule.dart';
import 'df_reminder_service.dart';

DfReminderService createReminderService() => NativeReminderService();

/// A tap that happens while the process is already gone (app not just
/// backgrounded) delivers here. Must be a top-level/static function per
/// flutter_local_notifications' isolate contract — the actual routing is
/// handled in the foreground via [NativeReminderService._onTap] instead, so
/// this stays a no-op.
@pragma('vm:entry-point')
void _dfNotificationBackgroundTap(NotificationResponse response) {}

/// Native (iOS/Android) implementation using flutter_local_notifications.
/// Reminders are scheduled at the OS level and fire even when the app is
/// closed.
class NativeReminderService implements DfReminderService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialised = false;
  String? _pendingPayload;

  @override
  Future<void> init() async {
    if (_initialised) return;
    tzdata.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _dfNotificationBackgroundTap,
    );

    // A tap that cold-launched the app doesn't go through the callback above
    // — it has to be read back explicitly once the plugin is initialised.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _pendingPayload = launchDetails!.notificationResponse?.payload;
    }
    _initialised = true;
  }

  void _onTap(NotificationResponse response) {
    _pendingPayload = response.payload;
  }

  @override
  String? consumePendingPayload() {
    final payload = _pendingPayload;
    _pendingPayload = null;
    return payload;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  @override
  Future<void> schedule(DfReminder reminder) async {
    await init();
    final fireAt = DfReminderSchedule.nextOccurrence(reminder, DateTime.now());
    if (fireAt == null) return;

    await _plugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
      notificationDetails: NotificationDetails(
        android: _androidDetails(reminder.channel),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _matchComponents(reminder.repeat),
      payload: reminder.payload,
    );
  }

  DateTimeComponents? _matchComponents(DfReminderRepeat repeat) {
    switch (repeat) {
      case DfReminderRepeat.none:
        return null;
      case DfReminderRepeat.daily:
        return DateTimeComponents.time;
      case DfReminderRepeat.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case DfReminderRepeat.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
    }
  }

  AndroidNotificationDetails _androidDetails(DfNotificationChannel channel) {
    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: _importance(channel.importance),
      priority: _priority(channel.importance),
    );
  }

  Importance _importance(DfNotificationImportance importance) {
    switch (importance) {
      case DfNotificationImportance.low:
        return Importance.low;
      case DfNotificationImportance.defaultImportance:
        return Importance.defaultImportance;
      case DfNotificationImportance.high:
        return Importance.high;
    }
  }

  Priority _priority(DfNotificationImportance importance) {
    switch (importance) {
      case DfNotificationImportance.low:
        return Priority.low;
      case DfNotificationImportance.defaultImportance:
        return Priority.defaultPriority;
      case DfNotificationImportance.high:
        return Priority.high;
    }
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelMany(Iterable<int> ids) async {
    await init();
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
  }
}
