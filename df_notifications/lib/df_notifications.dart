/// Platform-agnostic local reminder scheduling, with a soft-ask permission
/// flow.
///
/// Extracted from NaviCare's `CareTask`-coupled reminder layer merged with
/// the generic half of PsychDiary's `NotificationService` — neither app's
/// domain types (a task, a diary entry) live here. Apps map their own data
/// onto [DfReminder] and schedule it through [DfReminderService]:
///
/// ```dart
/// final service = ref.read(dfReminderServiceProvider);
/// await service.schedule(DfReminder(
///   id: DfNotificationIds.slot(0),
///   title: 'Time to journal',
///   body: 'Take a moment to reflect on your day.',
///   scheduledAt: DateTime(2026, 1, 1, 19, 0),
///   repeat: DfReminderRepeat.daily,
/// ));
/// ```
library;

export 'src/df_notification_ids.dart';
export 'src/df_notification_priming.dart';
export 'src/df_notification_strings.dart';
export 'src/df_reminder.dart';
export 'src/df_reminder_preferences.dart';
export 'src/df_reminder_schedule.dart';
export 'src/df_reminder_service.dart';
