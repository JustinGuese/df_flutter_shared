# df_notifications

Platform-agnostic local reminder scheduling (native + web) with a soft-ask
permission flow.

Extracted from NaviCare's `CareTask`-coupled reminder layer, merged with the
generic half of PsychDiary's `NotificationService` (tz init, cold-start
payload routing, a persisted daily-reminder toggle). Neither app's domain
types live here — apps map their own data (a task, a diary entry, a course
nudge) onto the package's neutral `DfReminder` model.

## Install

```yaml
dependencies:
  df_notifications:
    path: ../df_flutter_shared/df_notifications
```

## Usage

```dart
import 'package:df_notifications/df_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final service = ref.read(dfReminderServiceProvider);
await service.init();

await service.schedule(DfReminder(
  id: DfNotificationIds.slot(0),
  title: 'Time to journal',
  body: 'Take a moment to reflect on your day.',
  scheduledAt: DateTime(2026, 1, 1, 19, 0),
  repeat: DfReminderRepeat.daily,
  payload: 'diary_new_entry',
));

// Later, e.g. from a settings toggle:
await service.cancel(DfNotificationIds.slot(0));

// On the first frame, route a cold start / tap to the right screen:
final payload = service.consumePendingPayload();
```

Ask before you ask: the OS permission prompt can only be shown once per
install on most platforms, so show the in-app soft-ask first and only trigger
the real prompt if the user opts in.

```dart
final granted = await ensureDfNotificationPermission(
  context,
  ref,
  strings: const DfNotificationStrings(
    primingTitle: 'Never miss a check-in',
    primingBody: 'Turn on reminders so a quick nudge finds you at the right time.',
  ),
);
```

A persisted "remind me daily at HH:MM" toggle (enable switch + time picker,
surviving app restarts) is a separate, prefs-only helper — reschedule with
`DfReminderService.schedule` right after `save()`:

```dart
const prefs = DfReminderPreferences(storeKey: 'diary');
await prefs.save(hour: 19, minute: 30);
final time = await prefs.getTime(); // null while disabled
```

## The reserved id range

Notification ids are a flat `int` namespace shared with the OS. Apps that
schedule one reminder per backend entity (a task, a diary entry) typically
reuse that entity's own id. Standalone reminders (a daily nudge, a win-back
ping) instead pull from a reserved high range so the two conventions can
never collide:

```dart
abstract final class DfNotificationIds {
  static const int reservedRangeStart = 900000; // .. reservedRangeEnd = 999999
  static int slot(int n) => reservedRangeStart + n; // stable, asserts in range
}
```

Keep one `const` block per app naming what each slot means (mirroring
NaviCare's `engagement_reminders.dart`), so ids stay stable across releases:

```dart
const kDailyLearningReminderId = 900002; // was DfNotificationIds.slot(2)
const kWinBackReminderId = 900004;
```

## What's platform-specific

`DfReminderService` is a conditional-import split, resolved on
`dart.library.js_interop` (not the deprecated `dart.library.html`, which has
no Wasm equivalent):

- **Native** (`flutter_local_notifications` + `timezone`): reminders are
  scheduled at the OS level and fire even when the app is closed. Cold-start
  and in-session taps are both captured; read them back via
  `consumePendingPayload()`.
- **Web** (browser `Notification` API): a browser can only fire while the
  tab / installed PWA is running, so scheduling uses in-session `Timer`s.
  Pair this with an in-app "reminders due" surface for anything missed while
  the tab was closed. `consumePendingPayload()` always returns `null` on
  web — a notification click there does not hand back a payload the way a
  cold native launch does.

## What was dropped as app-specific

- NaviCare's `CareTask` coupling (`scheduleReminder(CareTask)`,
  `syncAll(List<CareTask>)`) — replaced by the neutral `DfReminder` model;
  apps write their own `syncAll` loop from `cancelMany` + `schedule`.
- NaviCare's fixed `ReminderCategory` enum (tasks/learning/knowledge/
  engagement) — replaced by an app-supplied `DfNotificationChannel`, since
  which categories exist is a per-app decision.
- All German copy — moved into `DfNotificationStrings`, English defaults,
  same pattern as `df_courses`' `CourseStrings`.
- PsychDiary's AI-personalized notification batch (`_buildHooks`,
  `_schedulePersonalizedBatch`, the AI-consent gate, `DiaryRepository`
  fetch) — inherently diary-specific; nothing here generalizes without
  reintroducing a domain type.
