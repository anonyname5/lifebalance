import 'package:intl/intl.dart';

/// Utility class for date and time operations
class DateHelper {
  /// Format date as "Tuesday, Dec 5, 2025"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  /// Format date as "Dec 5, 2025"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format time as "8:00 AM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date for database storage (YYYY-MM-DD)
  static String formatDateForDb(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format time for database storage (HH:mm:ss)
  static String formatTimeForDb(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }

  /// Parse date from database format (YYYY-MM-DD)
  static DateTime parseDateFromDb(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  /// Parse time from database format (HH:mm:ss)
  static DateTime parseTimeFromDb(String timeString) {
    return DateFormat('HH:mm:ss').parse(timeString);
  }

  /// Get today's date as string for database
  static String todayAsString() {
    return formatDateForDb(DateTime.now());
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Private constructor to prevent instantiation
  DateHelper._();
}
