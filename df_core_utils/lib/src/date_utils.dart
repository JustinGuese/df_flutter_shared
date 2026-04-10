import 'package:intl/intl.dart';

/// Extracts only the date portion (year, month, day) from a DateTime,
/// removing time information.
DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Formats a date for diary entry display.
/// Format: "EEEE, MMMM d, y" (e.g., "Monday, January 15, 2024")
String formatEntryDate(DateTime date) {
  return DateFormat('EEEE, MMMM d, y').format(date);
}

/// German short date. Format: "15.04.2025"
String formatGermanDate(DateTime date) {
  return DateFormat('dd.MM.yyyy', 'de_DE').format(date);
}

/// German date + time. Format: "15.04.2025 14:30"
String formatGermanDateTime(DateTime date) {
  return DateFormat('dd.MM.yyyy HH:mm', 'de_DE').format(date);
}

/// German long weekday format used in diary cards.
/// Format: "Dienstag, 15. April 2025"
String formatGermanEntryDate(DateTime date) {
  return DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(date);
}
