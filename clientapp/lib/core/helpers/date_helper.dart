import 'package:intl/intl.dart';

class AppDateHelper {
  /// Format a DateTime object into a readable string
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Parse a date string safely
  static DateTime? parseDate(
    String dateString, {
    String format = 'yyyy-MM-dd',
  }) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Convert UTC DateTime to Local Time
  static DateTime toLocalTime(DateTime dateTime) {
    return dateTime.toLocal();
  }

  /// Convert Local DateTime to UTC
  static DateTime toUtcTime(DateTime dateTime) {
    return dateTime.toUtc();
  }

  /// Get difference in days between two dates
  static int differenceInDays(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Get difference in hours between two dates
  static int differenceInHours(DateTime from, DateTime to) {
    return to.difference(from).inHours;
  }

  /// Get human-friendly time difference (e.g., "2 days ago", "5 hours ago")
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return formatDate(date, format: 'MMM d, yyyy');
    }
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
  }

  /// Check if a date is in the future
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Get current time in a specific format
  static String getCurrentTime({String format = 'HH:mm:ss'}) {
    return DateFormat(format).format(DateTime.now());
  }

  /// Get current date in a specific format
  static String getCurrentDate({String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(DateTime.now());
  }
}
