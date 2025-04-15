import 'package:intl/intl.dart';
import 'package:birthdate_plus/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class DateUtils {
  static String calculateAgeText(BuildContext context, DateTime birthDate) {
    print('Calculating age text for birthDate: ${birthDate.toIso8601String()}');
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      print('AppLocalizations is null, using fallback strings');
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
    print('Calculating detailed time stats for birthDate: ${birthDate.toIso8601String()}');
    try {
      final now = DateTime.now();
      print('Current time: ${now.toIso8601String()}');
      final difference = now.difference(birthDate);
      print('Time difference: ${difference.inDays} days');

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

      final result = {
        'Years': format.format(years),
        'Months': format.format(months),
        'Weeks': format.format(weeks),
        'Days': format.format(days),
        'Hours': format.format(hours),
        'Minutes': format.format(minutes),
        'Seconds': format.format(seconds),
      };
      
      print('Calculated time stats: $result');
      return result;
    } catch (e) {
      print('Error calculating time stats: $e');
      // Return zero values in case of error
      return {
        'Years': '0',
        'Months': '0',
        'Weeks': '0',
        'Days': '0',
        'Hours': '0',
        'Minutes': '0',
        'Seconds': '0',
      };
    }
  }

  static String getBirthstone(BuildContext context, int month) {
    print('Getting birthstone for month: $month');
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      print('AppLocalizations is null, using fallback strings');
      switch (month) {
        case 1:
          return 'Garnet';
        case 2:
          return 'Amethyst';
        case 3:
          return 'Aquamarine';
        case 4:
          return 'Diamond';
        case 5:
          return 'Emerald';
        case 6:
          return 'Pearl';
        case 7:
          return 'Ruby';
        case 8:
          return 'Peridot';
        case 9:
          return 'Sapphire';
        case 10:
          return 'Opal';
        case 11:
          return 'Topaz';
        case 12:
          return 'Turquoise';
        default:
          return '';
      }
    }

    String result = '';
    switch (month) {
      case 1:
        result = l10n.birthstoneGarnet;
        break;
      case 2:
        result = l10n.birthstoneAmethyst;
        break;
      case 3:
        result = l10n.birthstoneAquamarine;
        break;
      case 4:
        result = l10n.birthstoneDiamond;
        break;
      case 5:
        result = l10n.birthstoneEmerald;
        break;
      case 6:
        result = l10n.birthstonePearl;
        break;
      case 7:
        result = l10n.birthstoneRuby;
        break;
      case 8:
        result = l10n.birthstonePeridot;
        break;
      case 9:
        result = l10n.birthstoneSapphire;
        break;
      case 10:
        result = l10n.birthstoneOpal;
        break;
      case 11:
        result = l10n.birthstoneTopaz;
        break;
      case 12:
        result = l10n.birthstoneTurquoise;
        break;
      default:
        result = '';
    }
    print('Birthstone result: $result');
    return result;
  }

  static String getBirthFlower(BuildContext context, int month) {
    print('Getting birth flower for month: $month');
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      print('AppLocalizations is null, using fallback strings');
      switch (month) {
        case 1:
          return 'Carnation';
        case 2:
          return 'Violet';
        case 3:
          return 'Daffodil';
        case 4:
          return 'Daisy';
        case 5:
          return 'Lily of the Valley';
        case 6:
          return 'Rose';
        case 7:
          return 'Larkspur';
        case 8:
          return 'Gladiolus';
        case 9:
          return 'Aster';
        case 10:
          return 'Marigold';
        case 11:
          return 'Chrysanthemum';
        case 12:
          return 'Poinsettia';
        default:
          return '';
      }
    }

    String result = '';
    switch (month) {
      case 1:
        result = l10n.flowerCarnation;
        break;
      case 2:
        result = l10n.flowerViolet;
        break;
      case 3:
        result = l10n.flowerDaffodil;
        break;
      case 4:
        result = l10n.flowerDaisy;
        break;
      case 5:
        result = l10n.flowerLilyValley;
        break;
      case 6:
        result = l10n.flowerRose;
        break;
      case 7:
        result = l10n.flowerLarkspur;
        break;
      case 8:
        result = l10n.flowerGladiolus;
        break;
      case 9:
        result = l10n.flowerAster;
        break;
      case 10:
        result = l10n.flowerMarigold;
        break;
      case 11:
        result = l10n.flowerChrysanthemum;
        break;
      case 12:
        result = l10n.flowerPoinsettia;
        break;
      default:
        result = '';
    }
    print('Birth flower result: $result');
    return result;
  }

  static String getChineseZodiac(BuildContext context, int year) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      switch (year % 12) {
        case 0:
          return 'Monkey';
        case 1:
          return 'Rooster';
        case 2:
          return 'Dog';
        case 3:
          return 'Pig';
        case 4:
          return 'Rat';
        case 5:
          return 'Ox';
        case 6:
          return 'Tiger';
        case 7:
          return 'Rabbit';
        case 8:
          return 'Dragon';
        case 9:
          return 'Snake';
        case 10:
          return 'Horse';
        case 11:
          return 'Goat';
        default:
          return '';
      }
    }

    switch (year % 12) {
      case 0:
        return l10n.chineseMonkey;
      case 1:
        return l10n.chineseRooster;
      case 2:
        return l10n.chineseDog;
      case 3:
        return l10n.chinesePig;
      case 4:
        return l10n.chineseRat;
      case 5:
        return l10n.chineseOx;
      case 6:
        return l10n.chineseTiger;
      case 7:
        return l10n.chineseRabbit;
      case 8:
        return l10n.chineseDragon;
      case 9:
        return l10n.chineseSnake;
      case 10:
        return l10n.chineseHorse;
      case 11:
        return l10n.chineseGoat;
      default:
        return '';
    }
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
      if (year >= 2025) return 'Generation Beta';
      if (year >= 2010) return 'Generation Alpha';
      if (year >= 1997) return 'Generation Z';
      if (year >= 1981) return 'Millennial Generation';
      if (year >= 1965) return 'Generation X';
      if (year >= 1946) return 'Baby Boomer Generation';
      return 'Silent Generation';
    }

    if (year >= 2025) return l10n.generationBeta;
    if (year >= 2010) return l10n.generationAlpha;
    if (year >= 1997) return l10n.generationZ;
    if (year >= 1981) return l10n.generationMillennial;
    if (year >= 1965) return l10n.generationX;
    if (year >= 1946) return l10n.generationBabyBoomer;
    return l10n.generationSilent;
  }

  static String getZodiacSign(BuildContext context, int month, int day) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
      if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
      if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
      if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
      if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
      if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
      if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
      if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
      if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
      if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
      if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
      return 'Pisces';
    }

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return l10n.zodiacAries;
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return l10n.zodiacTaurus;
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return l10n.zodiacGemini;
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return l10n.zodiacCancer;
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return l10n.zodiacLeo;
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return l10n.zodiacVirgo;
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return l10n.zodiacLibra;
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return l10n.zodiacScorpio;
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return l10n.zodiacSagittarius;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return l10n.zodiacCapricorn;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return l10n.zodiacAquarius;
    return l10n.zodiacPisces;
  }
} 