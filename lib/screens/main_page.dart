import 'package:birthdate_plus/widgets/birthday_photo_card/birthday_photo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/anniversary_page.dart';
import '../screens/birth_facts_page.dart';
import '../screens/about_page.dart';
import '../screens/privacy_policy_page.dart';
import '../screens/contact_page.dart';

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
                          'Birthdate+',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                            letterSpacing: -1,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                              onPressed: () {
                                context.read<ThemeProvider>().toggleTheme();
                              },
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                              onSelected: (value) {
                                switch (value) {
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
                                  value: 'about',
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline),
                                      SizedBox(width: 8),
                                      Text('About Us'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'privacy',
                                  child: Row(
                                    children: [
                                      Icon(Icons.privacy_tip_outlined),
                                      SizedBox(width: 8),
                                      Text('Privacy Policy'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'contact',
                                  child: Row(
                                    children: [
                                      Icon(Icons.contact_mail_outlined),
                                      SizedBox(width: 8),
                                      Text('Contact Us'),
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
                                'Create Beautiful\nBirthday Cards',
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
                                'Discover fascinating facts about your birthday and create stunning shareable cards.',
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
                                    title: 'Birthday Cards',
                                    description: 'Create custom cards',
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
                                    title: 'Anniv. Cards',
                                    description: 'Calculate your exact age',
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
                                    title: 'Birth Facts',
                                    description: 'Zodiac, birthstone & more',
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
                                    title: 'Share',
                                    description: 'Share with friends',
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
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    height: 1.3,
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