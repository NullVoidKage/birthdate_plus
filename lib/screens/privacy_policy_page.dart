import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:birthdate_plus/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback to English strings if localization is not available
      return Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
        ),
        body: const Center(
          child: Text('Privacy Policy Page'),
        ),
      );
    }
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.privacyPolicy,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated: March 30, 2024',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: l10n.privacyPolicyIntroTitle,
                content: l10n.privacyPolicyIntroContent,
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: l10n.dataCollectionTitle,
                content: l10n.dataCollectionContent,
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: l10n.dataSharingTitle,
                content: l10n.dataSharingContent,
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: l10n.dataSecurityTitle,
                content: l10n.dataSecurityContent,
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: l10n.contactTitle,
                content: l10n.contactContent,
                isDarkMode: isDarkMode,
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required String content,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
} 