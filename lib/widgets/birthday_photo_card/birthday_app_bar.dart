import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      title: Text(
        'Birthdate',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          letterSpacing: 0.5,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 3.0,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white),
            offset: Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'time_format',
                child: ListTile(
                  leading: Icon(
                    showDetailedTime ? Icons.timer_outlined : Icons.calendar_today_outlined,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    showDetailedTime ? 'Show Age' : 'Show Time Details',
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
                    isObfuscated ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    isObfuscated ? 'Show Numbers' : 'Hide Numbers',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'customize',
                child: ListTile(
                  leading: Icon(
                    Icons.tune_outlined,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    'Customize',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'visibility',
                child: ListTile(
                  leading: Icon(
                    isInfoVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    isInfoVisible ? 'Hide Info' : 'Show Info',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'reset_all',
                child: ListTile(
                  leading: Icon(
                    Icons.restart_alt_rounded,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Reset Everything',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'time_format':
                  onTimeFormatToggle();
                  break;
                case 'customize':
                  onCustomize();
                  break;
                case 'visibility':
                  onVisibilityToggle();
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
        ),
      ],
    );
  }
} 