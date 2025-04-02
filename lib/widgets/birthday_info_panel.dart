import 'package:birthdate_plus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'package:intl/intl.dart';

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
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (!isInfoVisible || selectedDate == null) return SizedBox.shrink();

        final l10n = AppLocalizations.of(context);
        if (l10n == null) {
          // Fallback to English strings if localization is not available
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
                      'Current Age',
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
                          child: _infoItem('Birthstone', app_date_utils.DateUtils.getBirthstone(selectedDate!.month)),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _infoItem('Birth Flower', app_date_utils.DateUtils.getBirthFlower(selectedDate!.month)),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _infoItem('Chinese Zodiac', app_date_utils.DateUtils.getChineseZodiac(selectedDate!.year)),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _infoItem('Lucky Number', app_date_utils.DateUtils.getLuckyNumber(selectedDate!).toString()),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _infoItem('Zodiac Sign', _getZodiacSignFallback(selectedDate!.month, selectedDate!.day)),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _infoItem('Generation', app_date_utils.DateUtils.getGeneration(context, selectedDate!.year)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        String getBirthstone(int month) {
          final birthstones = [
            l10n.birthstoneGarnet,
            l10n.birthstoneAmethyst,
            l10n.birthstoneAquamarine,
            l10n.birthstoneDiamond,
            l10n.birthstoneEmerald,
            l10n.birthstonePearl,
            l10n.birthstoneRuby,
            l10n.birthstonePeridot,
            l10n.birthstoneSapphire,
            l10n.birthstoneOpal,
            l10n.birthstoneTopaz,
            l10n.birthstoneTurquoise
          ];
          return birthstones[month - 1];
        }

        String getBirthFlower(int month) {
          final birthFlowers = [
            l10n.flowerCarnation,
            l10n.flowerViolet,
            l10n.flowerDaffodil,
            l10n.flowerDaisy,
            l10n.flowerLilyValley,
            l10n.flowerRose,
            l10n.flowerLarkspur,
            l10n.flowerGladiolus,
            l10n.flowerAster,
            l10n.flowerMarigold,
            l10n.flowerChrysanthemum,
            l10n.flowerPoinsettia
          ];
          return birthFlowers[month - 1];
        }

        String getChineseZodiac(int year) {
          final zodiacs = [
            l10n.chineseMonkey,
            l10n.chineseRooster,
            l10n.chineseDog,
            l10n.chinesePig,
            l10n.chineseRat,
            l10n.chineseOx,
            l10n.chineseTiger,
            l10n.chineseRabbit,
            l10n.chineseDragon,
            l10n.chineseSnake,
            l10n.chineseHorse,
            l10n.chineseGoat
          ];
          return zodiacs[year % 12];
        }

        String getZodiacSign(int month, int day) {
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

        int getLuckyNumber(DateTime birthDate) {
          int sum = birthDate.year + birthDate.month + birthDate.day;
          while (sum >= 10) {
            sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
          }
          return sum;
        }

        final birthstone = getBirthstone(selectedDate!.month);
        final birthFlower = getBirthFlower(selectedDate!.month);
        final chineseZodiac = getChineseZodiac(selectedDate!.year);
        final luckyNumber = getLuckyNumber(selectedDate!);
        final zodiacSign = getZodiacSign(selectedDate!.month, selectedDate!.day);
        
        final generation = app_date_utils.DateUtils.getGeneration(context, selectedDate!.year);

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
                    l10n.currentAge,
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
                        child: _infoItem(l10n.birthstone, birthstone),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _infoItem(l10n.birthFlower, birthFlower),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(l10n.chineseZodiac, chineseZodiac),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _infoItem(l10n.luckyNumber, luckyNumber.toString()),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(l10n.zodiacSign, zodiacSign),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _infoItem(l10n.generation, generation),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getZodiacSignFallback(int month, int day) {
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
} 