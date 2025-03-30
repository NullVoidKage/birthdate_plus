import 'package:intl/intl.dart';

class DateUtils {
  static String calculateAgeText(DateTime? birthDate, bool isObfuscated) {
    if (birthDate == null) return '';
    
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return 'Invalid date';
    
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

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

    // Format the date
    final dateFormatter = DateFormat('MMMM d, yyyy');
    String formattedDate = dateFormatter.format(birthDate);

    // Obfuscate the text if enabled
    if (isObfuscated) {
      formattedDate = formattedDate.replaceAll(RegExp(r'\d'), '*');
    }

    // Format the output
    if (years == 0) {
      if (months == 0) {
        return '$days days old - $formattedDate';
      }
      return '$months months, $days days - $formattedDate';
    }
    
    return '${isObfuscated ? '**' : years} y/o - $formattedDate';
  }

  static Map<String, String> getDetailedTimeStats(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);

    final format = NumberFormat("#,###"); // Adds comma as thousands separator

    // Calculate various time units
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds;

    // Calculate weeks and months (approximate)
    final weeks = (days / 7).floor();
    final months = (days / 30.44).floor(); // Average days per month
    final years = (days / 365.25).floor(); // Account for leap years

    return {
      'Years': format.format(years),
      'Months': format.format(months),
      'Weeks': format.format(weeks),
      'Days': format.format(days),
      'Hours': format.format(hours),
      'Minutes': format.format(minutes),
      'Seconds': format.format(seconds),
    };
  }

  static String getBirthstone(int month) {
    const birthstones = [
      'Garnet',
      'Amethyst',
      'Aquamarine',
      'Diamond',
      'Emerald',
      'Pearl',
      'Ruby',
      'Peridot',
      'Sapphire',
      'Opal',
      'Topaz',
      'Turquoise'
    ];
    return birthstones[month - 1];
  }

  static String getBirthFlower(int month) {
    const birthFlowers = [
      'Carnation',
      'Violet',
      'Daffodil',
      'Daisy',
      'Lily of the Valley',
      'Rose',
      'Larkspur',
      'Gladiolus',
      'Aster',
      'Marigold',
      'Chrysanthemum',
      'Poinsettia'
    ];
    return birthFlowers[month - 1];
  }

  static String getChineseZodiac(int year) {
    const zodiacs = [
      'Monkey',
      'Rooster',
      'Dog',
      'Pig',
      'Rat',
      'Ox',
      'Tiger',
      'Rabbit',
      'Dragon',
      'Snake',
      'Horse',
      'Goat'
    ];
    return zodiacs[year % 12];
  }

  static int getLuckyNumber(DateTime birthDate) {
    int sum = birthDate.year + birthDate.month + birthDate.day;
    while (sum >= 10) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  static String getGeneration(int year) {
    if (year >= 2025) return 'Generation Beta';  // Emerging generation
    if (year >= 2010) return 'Generation Alpha';
    if (year >= 1997) return 'Gen Z';
    if (year >= 1981) return 'Millennial';
    if (year >= 1965) return 'Gen X';
    if (year >= 1946) return 'Baby Boomer';
    return 'Silent Generation';
  }
} 