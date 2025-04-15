import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:birthdate_plus/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/preferences_service.dart';
import '../../screens/main_page.dart';

class BirthdayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDetailedTime;
  final bool isObfuscated;
  final bool isInfoVisible;
  final VoidCallback onTimeFormatToggle;
  final VoidCallback onCustomize;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onObfuscateToggle;
  final VoidCallback onResetAll;

  const BirthdayAppBar({
    Key? key,
    required this.showDetailedTime,
    required this.isObfuscated,
    required this.isInfoVisible,
    required this.onTimeFormatToggle,
    required this.onCustomize,
    required this.onVisibilityToggle,
    required this.onObfuscateToggle,
    required this.onResetAll,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n?.language ?? 'Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(context, 'English', 'en'),
                _buildLanguageOption(context, 'Español', 'es'),
                _buildLanguageOption(context, 'हिंदी', 'hi'),
                _buildLanguageOption(context, 'Português', 'pt'),
                _buildLanguageOption(context, '中文', 'zh'),
                _buildLanguageOption(context, '한국어', 'ko'),
                _buildLanguageOption(context, '日本語', 'ja'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String label, String code) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isSelected = languageProvider.currentLocale.languageCode == code;
        return ListTile(
          title: Text(label),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () async {
            print('Language option tapped: $code');
            // Set new language
            await languageProvider.setLanguage(code);
            if (context.mounted) {
              // Pop the dialog
              Navigator.pop(context);
              // Force rebuild by popping to first route and pushing new instance
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final l10n = AppLocalizations.of(context);

        return AppBar(
          backgroundColor: Colors.black.withOpacity(0.2),
          elevation: 0,
          centerTitle: true,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          title: Text(
            l10n?.birthdayCards ?? 'Birthday Cards',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 24,
              letterSpacing: 0.5,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                showDetailedTime ? Icons.timer : Icons.timer_outlined,
                color: Colors.white,
              ),
              onPressed: onTimeFormatToggle,
            ),
            IconButton(
              icon: Icon(
                isInfoVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: onVisibilityToggle,
            ),
            IconButton(
              icon: const Icon(
                Icons.palette_outlined,
                color: Colors.white,
              ),
              onPressed: onCustomize,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'language',
                  child: ListTile(
                    leading: Icon(
                      Icons.language,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      l10n?.language ?? 'Language',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'obfuscate',
                  child: ListTile(
                    leading: Icon(
                      isObfuscated ? Icons.lock : Icons.lock_open,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      isObfuscated ? 'Show Details' : 'Hide Details',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'reset_all',
                  child: ListTile(
                    leading: Icon(
                      Icons.refresh,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      l10n?.resetAll ?? 'Reset All',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'language':
                    _showLanguageDialog(context);
                    break;
                  case 'obfuscate':
                    onObfuscateToggle();
                    break;
                  case 'reset_all':
                    onResetAll();
                    break;
                }
              },
            ),
          ],
        );
      },
    );
  }
} 