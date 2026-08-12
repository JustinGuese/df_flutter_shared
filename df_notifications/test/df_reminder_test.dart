import 'package:df_notifications/df_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfReminder', () {
    final base = DfReminder(
      id: 1,
      title: 'Title',
      body: 'Body',
      scheduledAt: DateTime(2026, 1, 1, 9, 0),
    );

    test('equality is value-based, keyed off id/content/repeat/channel', () {
      final same = DfReminder(
        id: 1,
        title: 'Title',
        body: 'Body',
        scheduledAt: DateTime(2026, 1, 1, 9, 0),
      );
      expect(base, same);
      expect(base.hashCode, same.hashCode);

      final differentTitle = base.copyWith(title: 'Other');
      expect(base, isNot(differentTitle));
    });

    test('copyWith overrides only the given fields', () {
      final updated = base.copyWith(
        scheduledAt: DateTime(2026, 2, 2, 10, 30),
        repeat: DfReminderRepeat.daily,
      );
      expect(updated.id, base.id);
      expect(updated.title, base.title);
      expect(updated.scheduledAt, DateTime(2026, 2, 2, 10, 30));
      expect(updated.repeat, DfReminderRepeat.daily);
    });

    test('defaults to a one-shot on the default channel', () {
      expect(base.repeat, DfReminderRepeat.none);
      expect(base.channel.id, DfNotificationChannel.defaultChannel.id);
      expect(base.payload, isNull);
    });
  });
}
