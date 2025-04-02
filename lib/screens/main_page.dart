import 'package:birthdate_plus/screens/birthday_photo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:birthdate_plus/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../screens/anniversary_page.dart';
import '../screens/birth_facts_page.dart';
import '../screens/about_page.dart';
import '../screens/privacy_policy_page.dart';
import '../screens/contact_page.dart';
import '../widgets/app_logo.dart';
import '../services/premium_service.dart';
import '../widgets/birthday_photo_card/premium_modal.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (!languageProvider.isInitialized) {
          return Scaffold(
            backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFFAFAFA),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Initializing...',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Wait for AppLocalizations to be available
        return FutureBuilder<AppLocalizations>(
          future: AppLocalizations.delegate.load(languageProvider.currentLocale),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFFAFAFA),
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading translations...',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              print('Error loading translations: ${snapshot.error}');
              return Scaffold(
                backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFFAFAFA),
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        'Error loading translations',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final l10n = snapshot.data;
            if (l10n == null) {
              return Scaffold(
                backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFFAFAFA),
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        'Translations not available',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            
            return Scaffold(
              backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFFAFAFA),
              body: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode 
                          ? [Color(0xFF2C2C2C), Color(0xFF1A1A1A)]
                          : [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
                      ),
                    ),
                  ),
                  
                  // Content
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Bar
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n?.appTitle ?? 'Birthdate+',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    letterSpacing: -1,
                                  ),
                                ),
                                Row(
                                  children: [
                                    // AppLogo(size: 32),
                                    SizedBox(width: 16),
                                    IconButton(
                                      icon: Icon(
                                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                      ),
                                      onPressed: () {
                                        context.read<ThemeProvider>().toggleTheme();
                                      },
                                    ),
                                    FutureBuilder<bool>(
                                      future: PremiumService.isPremium(),
                                      builder: (context, snapshot) {
                                        final isPremium = snapshot.data ?? false;
                                        return IconButton(
                                          icon: Icon(
                                            isPremium ? Icons.star : Icons.star_border,
                                            color: isPremium ? Colors.amber : (isDarkMode ? Colors.white70 : Colors.black54),
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => PremiumModal(
                                                onUpgrade: () {
                                                  setState(() {}); // Refresh UI
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                      ),
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'language':
                                            _showLanguageDialog(context);
                                            break;
                                          case 'about':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AboutPage(),
                                              ),
                                            );
                                            break;
                                          case 'privacy':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PrivacyPolicyPage(),
                                              ),
                                            );
                                            break;
                                          case 'contact':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ContactPage(),
                                              ),
                                            );
                                            break;
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        PopupMenuItem<String>(
                                          value: 'language',
                                          child: Row(
                                            children: [
                                              Icon(Icons.language),
                                              SizedBox(width: 8),
                                              Text(l10n?.language ?? 'Select Language'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'about',
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline),
                                              SizedBox(width: 8),
                                              Text(l10n?.aboutUs ?? 'About Us'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'privacy',
                                          child: Row(
                                            children: [
                                              Icon(Icons.privacy_tip_outlined),
                                              SizedBox(width: 8),
                                              Text(l10n?.privacyPolicy ?? 'Privacy Policy'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'contact',
                                          child: Row(
                                            children: [
                                              Icon(Icons.contact_mail_outlined),
                                              SizedBox(width: 8),
                                              Text(l10n?.contactUs ?? 'Contact Us'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 40),
                                  
                                  // Main heading
                                  SlideTransition(
                                    position: _slideAnimation,
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Text(
                                        l10n?.createBeautifulCards ?? 'Create Beautiful Cards',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                          letterSpacing: -1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),
                                  
                                  // Subtitle
                                  SlideTransition(
                                    position: _slideAnimation,
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Text(
                                        l10n?.discoverFacts ?? 'Discover Facts',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: isDarkMode ? Colors.white70 : Colors.black54,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 60),

                                  // Features grid
                                  SlideTransition(
                                    position: _slideAnimation,
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: GridView.count(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        childAspectRatio: 1.05,
                                        children: [
                                          _buildFeatureCard(
                                            icon: Icons.photo_camera,
                                            title: l10n?.birthdayCards ?? 'Birthday Cards',
                                            description: l10n?.createCustomCards ?? 'Create Custom Cards',
                                            isDarkMode: isDarkMode,
                                            gradient: [Colors.orange, Colors.deepOrange],
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BirthdayPhotoCard(),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildFeatureCard(
                                            icon: Icons.cake_outlined,
                                            title: l10n?.anniversaryCards ?? 'Anniversary Cards',
                                            description: l10n?.calculateExactAge ?? 'Calculate Exact Age',
                                            isDarkMode: isDarkMode,
                                            gradient: [Colors.purple, Colors.deepPurple],
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AnniversaryPage(),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildFeatureCard(
                                            icon: Icons.auto_awesome,
                                            title: l10n?.birthFacts ?? 'Birth Facts',
                                            description: l10n?.zodiacAndMore ?? 'Zodiac and More',
                                            isDarkMode: isDarkMode,
                                            gradient: [Colors.blue, Colors.blueAccent],
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BirthFactsPage(),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildFeatureCard(
                                            icon: Icons.share,
                                            title: l10n?.share ?? 'Share',
                                            description: l10n?.shareWithFriends ?? 'Share with Friends',
                                            isDarkMode: isDarkMode,
                                            gradient: [Colors.green, Colors.teal],
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BirthdayPhotoCard(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
          trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
          onTap: () async {
            print('Selected language: $code');
            await languageProvider.setLanguage(code);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradient[0].withOpacity(0.1),
                gradient[1].withOpacity(0.2),
              ],
            ),
            border: Border.all(
              color: gradient[0].withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 