import 'package:intl/intl.dart';

class DateCalculator {
  static Map<String, int> calculateDuration(DateTime startDate) {
    final end = DateTime(2025, 4, 2); // Using fixed end date for testing
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    
    // Initialize counters
    int years = 0;
    int months = 0;
    int days = 0;
    
    // Calculate the total number of days
    final difference = end.difference(start);
    final totalDays = difference.inDays;
    
    // Use a temporary date to count months and years
    DateTime temp = start;
    
    // Count completed years
    while (temp.add(const Duration(days: 365)).isBefore(end) || 
           temp.add(const Duration(days: 365)).isAtSameMomentAs(end)) {
      years++;
      temp = DateTime(temp.year + 1, temp.month, temp.day);
    }
    
    // Count completed months after years
    while (true) {
      DateTime nextMonth;
      if (temp.month == 12) {
        nextMonth = DateTime(temp.year + 1, 1, temp.day);
      } else {
        nextMonth = DateTime(temp.year, temp.month + 1, temp.day);
      }
      
      if (nextMonth.isBefore(end) || nextMonth.isAtSameMomentAs(end)) {
        months++;
        temp = nextMonth;
      } else {
        break;
      }
    }
    
    // Calculate remaining days
    days = end.difference(temp).inDays;
    
    // Calculate weeks for stats
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
    final duration = calculateDuration(date);
    final months = duration['months']!;
    final days = duration['days']!;

    if (months == 0) {
      return '$days ${days == 1 ? 'day' : 'days'}';
    } else {
      return '$months ${months == 1 ? 'month' : 'months'} and $days ${days == 1 ? 'day' : 'days'}';
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