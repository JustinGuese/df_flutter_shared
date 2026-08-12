import 'package:df_notifications/df_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfNotificationIds', () {
    test('slot(0) is the start of the reserved range', () {
      expect(DfNotificationIds.slot(0), DfNotificationIds.reservedRangeStart);
    });

    test('slots are stable offsets, never colliding with each other', () {
      expect(DfNotificationIds.slot(1), DfNotificationIds.slot(0) + 1);
      expect(DfNotificationIds.slot(5), DfNotificationIds.slot(0) + 5);
    });

    test('slot() rejects a negative index', () {
      expect(() => DfNotificationIds.slot(-1), throwsA(isA<AssertionError>()));
    });

    test('isReserved is true only inside the reserved range', () {
      expect(DfNotificationIds.isReserved(DfNotificationIds.slot(0)), isTrue);
      expect(
        DfNotificationIds.isReserved(DfNotificationIds.reservedRangeEnd),
        isTrue,
      );
      // A typical backend auto-increment id sits well below the range.
      expect(DfNotificationIds.isReserved(42), isFalse);
      expect(
        DfNotificationIds.isReserved(DfNotificationIds.reservedRangeStart - 1),
        isFalse,
      );
    });
  });
}
