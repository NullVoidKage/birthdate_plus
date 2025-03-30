import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class BirthdayInfoPanel extends StatelessWidget {
  final double fontSize;
  final Color textColor;
  final double opacity;
  final bool showDetailedTime;
  final bool isInfoVisible;
  final DateTime? selectedDate;
  final String ageText;

  const BirthdayInfoPanel({
    Key? key,
    required this.fontSize,
    required this.textColor,
    required this.opacity,
    required this.showDetailedTime,
    required this.isInfoVisible,
    required this.selectedDate,
    required this.ageText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isInfoVisible || selectedDate == null) return SizedBox.shrink();

    final birthstone = _getBirthstone(selectedDate!.month);
    final birthFlower = _getBirthFlower(selectedDate!.month);
    final chineseZodiac = _getChineseZodiac(selectedDate!.year);
    final luckyNumber = _getLuckyNumber(selectedDate!);
    final generation = _getGeneration(selectedDate!.year);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Age',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: fontSize - 4,
                ),
              ),
              Text(
                ageText,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black54,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _infoItem('Birthstone', birthstone),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _infoItem('Birth Flower', birthFlower),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _infoItem('Chinese Zodiac', chineseZodiac),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _infoItem('Lucky Number', luckyNumber.toString()),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _infoItem('Zodiac Sign', _getZodiacSign(selectedDate!.month, selectedDate!.day)),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _infoItem('Generation', generation),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Container(
      constraints: BoxConstraints(minWidth: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: fontSize - 4,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBirthstone(int month) {
    const birthstones = [
      'Garnet', 'Amethyst', 'Aquamarine', 'Diamond', 'Emerald', 'Pearl',
      'Ruby', 'Peridot', 'Sapphire', 'Opal', 'Topaz', 'Turquoise'
    ];
    return birthstones[month - 1];
  }

  String _getBirthFlower(int month) {
    const birthFlowers = [
      'Carnation', 'Violet', 'Daffodil', 'Daisy', 'Lily of the Valley', 'Rose',
      'Larkspur', 'Gladiolus', 'Aster', 'Marigold', 'Chrysanthemum', 'Poinsettia'
    ];
    return birthFlowers[month - 1];
  }

  String _getChineseZodiac(int year) {
    const zodiacs = [
      'Monkey', 'Rooster', 'Dog', 'Pig', 'Rat', 'Ox',
      'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Goat'
    ];
    return zodiacs[year % 12];
  }

  int _getLuckyNumber(DateTime birthDate) {
    int sum = birthDate.year + birthDate.month + birthDate.day;
    while (sum >= 10) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  String _getZodiacSign(int month, int day) {
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

  String _getGeneration(int year) {
    if (year >= 2025) return 'Generation Beta';
    if (year >= 2010) return 'Generation Alpha';
    if (year >= 1997) return 'Gen Z';
    if (year >= 1981) return 'Millennial';
    if (year >= 1965) return 'Gen X';
    if (year >= 1946) return 'Baby Boomer';
    return 'Silent Generation';
  }
} 