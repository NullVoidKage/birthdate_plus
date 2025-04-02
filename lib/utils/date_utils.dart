import 'package:intl/intl.dart';
import 'package:birthdate_plus/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class DateUtils {
  static String calculateAgeText(BuildContext context, DateTime birthDate) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback to English strings if localization is not available
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      final monthDiff = now.month - birthDate.month;
      
      if (monthDiff < 0 || (monthDiff == 0 && now.day < birthDate.day)) {
        if (age == 0) {
          return "Less than a year old";
        }
        return "${age - 1} years old";
      }
      
      if (age == 0) {
        if (monthDiff == 0) {
          return "Less than a month old";
        }
        return "$monthDiff months old";
      }
      
      return "$age years old";
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;
    final monthDiff = now.month - birthDate.month;
    
    if (monthDiff < 0 || (monthDiff == 0 && now.day < birthDate.day)) {
      if (age == 0) {
        return "Less than a year old";
      }
      return "${age - 1} ${l10n.years} old";
    }
    
    if (age == 0) {
      if (monthDiff == 0) {
        return "Less than a month old";
      }
      return "$monthDiff ${l10n.months} old";
    }
    
    return "$age ${l10n.years} old";
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

  static String getGeneration(BuildContext context, int year) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback to English strings if localization is not available
      if (year >= 2025) return 'Generation Beta';
      if (year >= 2010) return 'Generation Alpha';
      if (year >= 1997) return 'Generation Z';
      if (year >= 1981) return 'Generation Millennial';
      if (year >= 1965) return 'Generation X';
      if (year >= 1946) return 'Generation Baby Boomer';
      return 'Generation Silent';
    }
    
    if (year >= 2025) return l10n.generationBeta;
    if (year >= 2010) return l10n.generationAlpha;
    if (year >= 1997) return l10n.generationZ;
    if (year >= 1981) return l10n.generationMillennial;
    if (year >= 1965) return l10n.generationX;
    if (year >= 1946) return l10n.generationBabyBoomer;
    return l10n.generationSilent;
  }
} 