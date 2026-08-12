/// Reserved id range for standalone reminders (daily nudges, win-back pings,
/// course reminders — anything not tied to a backend record).
///
/// Apps that also schedule a reminder per backend entity (a task, a diary
/// entry) typically use that entity's own auto-increment id as the
/// notification id, which is why this range starts high: it must stay clear
/// of realistic backend ids for the lifetime of the app. Standalone
/// reminders should call [DfNotificationIds.slot] rather than picking a
/// literal, so two features can never collide on the same id by accident.
abstract final class DfNotificationIds {
  /// First id in the reserved range, inclusive.
  static const int reservedRangeStart = 900000;

  /// Last id in the reserved range, inclusive.
  static const int reservedRangeEnd = 999999;

  /// The id for reserved slot [n] (0-based). Keep a single source of truth
  /// per app for which slot means what — e.g. a `const` block of
  /// `DfNotificationIds.slot(0)` for "daily learning", `slot(1)` for
  /// "win-back" — the way `engagement_reminders.dart` did with named
  /// constants, so ids stay stable across app versions.
  static int slot(int n) {
    assert(n >= 0, 'slot index must not be negative');
    final id = reservedRangeStart + n;
    assert(
      id <= reservedRangeEnd,
      'slot $n exceeds the reserved id range ($reservedRangeStart..$reservedRangeEnd)',
    );
    return id;
  }

  /// Whether [id] falls inside the reserved range. Useful for an assertion at
  /// the call site of a standalone reminder, to catch an accidental literal
  /// that collides with a backend-entity id.
  static bool isReserved(int id) =>
      id >= reservedRangeStart && id <= reservedRangeEnd;
}
