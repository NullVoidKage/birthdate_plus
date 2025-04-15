import 'package:birthdate_plus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;

class BirthdayInfoPanel extends StatelessWidget {
  final DateTime birthDate;

  const BirthdayInfoPanel({
    Key? key,
    required this.birthDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building BirthdayInfoPanel with date: ${birthDate.toIso8601String()}');
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        print('BirthdayInfoPanel Consumer builder called');
        print('Current locale: ${languageProvider.currentLocale}');
        
        // Force rebuild when locale changes
        final currentLocale = languageProvider.currentLocale;
        final l10n = AppLocalizations.of(context);
        
        if (l10n == null) {
          print('AppLocalizations is null');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        print('Calculating time stats...');
        final timeStats = app_date_utils.DateUtils.getDetailedTimeStats(birthDate);
        print('Time stats calculated: $timeStats');

        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Age section
              _buildSection(
                context,
                l10n.currentAge,
                Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  children: timeStats.entries.map((entry) {
                    return _buildStatItem(
                      context,
                      entry.key,
                      entry.value,
                    );
                  }).toList(),
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              // Birthday Info section
              _buildSection(
                context,
                l10n.birthFacts,
                Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  children: [
                    _infoItem(
                      l10n.birthstone,
                      app_date_utils.DateUtils.getBirthstone(context, birthDate.month),
                    ),
                    _infoItem(
                      l10n.birthFlower,
                      app_date_utils.DateUtils.getBirthFlower(context, birthDate.month),
                    ),
                    _infoItem(
                      l10n.chineseZodiac,
                      app_date_utils.DateUtils.getChineseZodiac(context, birthDate.year),
                    ),
                    _infoItem(
                      l10n.luckyNumber,
                      app_date_utils.DateUtils.getLuckyNumber(birthDate).toString(),
                    ),
                    _infoItem(
                      l10n.zodiacSign,
                      app_date_utils.DateUtils.getZodiacSign(context, birthDate.month, birthDate.day),
                    ),
                    _infoItem(
                      l10n.generation,
                      app_date_utils.DateUtils.getGeneration(context, birthDate.year),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    print('Building section: $title');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    String localizedLabel = label;
    switch (label) {
      case 'Years':
        localizedLabel = l10n.years;
        break;
      case 'Months':
        localizedLabel = l10n.months;
        break;
      case 'Days':
        localizedLabel = l10n.days;
        break;
      case 'Weeks':
        localizedLabel = l10n.weeks;
        break;
    }
    print('Building stat item: $localizedLabel = $value');
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedLabel,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    print('Building info item: $label = $value');
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 