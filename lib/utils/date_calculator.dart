import 'package:intl/intl.dart';

class DateCalculator {
  static Map<String, int> calculateDuration(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate);

    // Calculate years
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;

    // Adjust for negative days
    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month - 1, 0).day;
    }

    // Adjust for negative months
    if (months < 0) {
      years--;
      months += 12;
    }

    // Calculate total days and weeks
    final totalDays = difference.inDays;
    final totalWeeks = (totalDays / 7).floor();
    final remainingDays = totalDays % 7;

    return {
      'years': years,
      'months': months,
      'days': days,
      'totalDays': totalDays,
      'totalWeeks': totalWeeks,
      'remainingDays': remainingDays,
    };
  }

  static String getDateComparisonText(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final totalDays = difference.inDays;

    if (totalDays < 365) {
      final months = (totalDays / 30.44).floor();
      final remainingDays = totalDays % 30;
      return '$months months and $remainingDays days';
    } else {
      final years = (totalDays / 365.25).floor();
      final remainingDays = (totalDays % 365.25).floor();
      return '$years years and $remainingDays days';
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat("MMMM d, y").format(date);
  }

  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365.25).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30.44).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 