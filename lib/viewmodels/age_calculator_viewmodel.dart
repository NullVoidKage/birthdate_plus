import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgeCalculatorViewModel extends ChangeNotifier {
  DateTime? selectedDate;

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  String calculateAge() {
    if (selectedDate == null) return '';
    
    final now = DateTime.now();
    if (selectedDate!.isAfter(now)) return 'Invalid date';
    
    int years = now.year - selectedDate!.year;
    int months = now.month - selectedDate!.month;
    int days = now.day - selectedDate!.day;

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

    // Format the output
    if (years == 0) {
      if (months == 0) {
        return '$days days old';
      }
      return '$months months, $days days';
    }
    
    return '$years y/o';
  }

  Map<String, String> getDetailedTimeStats(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);

    final format = NumberFormat("#,###");

    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds;

    final weeks = (days / 7).floor();
    final months = (days / 30.44).floor();
    final years = (days / 365.25).floor();

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

  String getBirthstone(int month) {
    const birthstones = [
      'Garnet', 'Amethyst', 'Aquamarine', 'Diamond', 'Emerald', 'Pearl',
      'Ruby', 'Peridot', 'Sapphire', 'Opal', 'Topaz', 'Turquoise'
    ];
    return birthstones[month - 1];
  }

  String getBirthFlower(int month) {
    const birthFlowers = [
      'Carnation', 'Violet', 'Daffodil', 'Daisy', 'Lily of the Valley', 'Rose',
      'Larkspur', 'Gladiolus', 'Aster', 'Marigold', 'Chrysanthemum', 'Poinsettia'
    ];
    return birthFlowers[month - 1];
  }

  String getChineseZodiac(int year) {
    const zodiacs = [
      'Monkey', 'Rooster', 'Dog', 'Pig', 'Rat', 'Ox',
      'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Goat'
    ];
    return zodiacs[year % 12];
  }

  int getLuckyNumber(DateTime birthDate) {
    int sum = birthDate.year + birthDate.month + birthDate.day;
    while (sum >= 10) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  String getGeneration(int year) {
    if (year >= 2025) return 'Generation Beta';
    if (year >= 2010) return 'Generation Alpha';
    if (year >= 1997) return 'Gen Z';
    if (year >= 1981) return 'Millennial';
    if (year >= 1965) return 'Gen X';
    if (year >= 1946) return 'Baby Boomer';
    return 'Silent Generation';
  }
} 