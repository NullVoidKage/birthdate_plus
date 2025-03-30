import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFFAFAFA),
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
          'Privacy Policy',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20),
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
              
              SizedBox(height: 24),
              
              _buildSection(
                title: 'Introduction',
                content: 'Birthdate+ is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: 'Information We Collect',
                content: 'We collect the following types of information:\n\n'
                    '• Birth date information that you voluntarily provide\n'
                    '• Photos that you choose to include in birthday cards\n'
                    '• Device information for app functionality\n'
                    '• Usage statistics to improve our services',
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: 'How We Use Your Information',
                content: 'We use the collected information to:\n\n'
                    '• Generate birthday cards and facts\n'
                    '• Improve app functionality\n'
                    '• Provide personalized content\n'
                    '• Enhance user experience',
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: 'Data Storage',
                content: 'Your data is stored securely on our servers. We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: 'Third-Party Services',
                content: 'We may use third-party services that collect information about you. These services are used for:\n\n'
                    '• Analytics\n'
                    '• Cloud storage\n'
                    '• Social sharing features',
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: 'Your Rights',
                content: 'You have the right to:\n\n'
                    '• Access your personal data\n'
                    '• Correct inaccurate data\n'
                    '• Request deletion of your data\n'
                    '• Opt-out of data collection',
                isDarkMode: isDarkMode,
              ),
              
              _buildSection(
                title: 'Contact Us',
                content: 'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                    'Email: privacy@birthdateplus.app',
                isDarkMode: isDarkMode,
              ),
              
              SizedBox(height: 40),
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
      padding: EdgeInsets.only(bottom: 24),
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
          SizedBox(height: 8),
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