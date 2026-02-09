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
