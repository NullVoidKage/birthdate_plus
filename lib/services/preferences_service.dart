import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static Future<void> savePreferences({
    required double fontSize,
    required double opacity,
    required bool showDetailedTime,
    required bool isInfoVisible,
    required bool isObfuscated,
    DateTime? selectedDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save text customization settings
      await prefs.setDouble('fontSize', fontSize);
      await prefs.setDouble('opacity', opacity);
      await prefs.setBool('showDetailedTime', showDetailedTime);
      await prefs.setBool('isInfoVisible', isInfoVisible);
      await prefs.setBool('isObfuscated', isObfuscated);
      
      // Save selected date
      if (selectedDate != null) {
        await prefs.setString('selectedDate', selectedDate.toIso8601String());
      }
      
      print('Preferences saved successfully: fontSize=$fontSize, opacity=$opacity, date=${selectedDate?.toIso8601String()}');
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  static Future<Map<String, dynamic>> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load text customization settings
      final savedFontSize = prefs.getDouble('fontSize');
      final savedOpacity = prefs.getDouble('opacity');
      final savedShowDetailedTime = prefs.getBool('showDetailedTime');
      final savedIsInfoVisible = prefs.getBool('isInfoVisible');
      final savedIsObfuscated = prefs.getBool('isObfuscated');
      
      // Load selected date
      final savedDateString = prefs.getString('selectedDate');
      DateTime? selectedDate;
      if (savedDateString != null) {
        selectedDate = DateTime.parse(savedDateString);
      }

      print('Preferences loaded successfully: fontSize=$savedFontSize, opacity=$savedOpacity, date=${selectedDate?.toIso8601String()}');
      
      return {
        'fontSize': savedFontSize ?? 18.0,
        'opacity': savedOpacity ?? 0.7,
        'showDetailedTime': savedShowDetailedTime ?? false,
        'isInfoVisible': savedIsInfoVisible ?? true,
        'isObfuscated': savedIsObfuscated ?? false,
        'selectedDate': selectedDate,
      };
    } catch (e) {
      print('Error loading preferences: $e');
      return {
        'fontSize': 18.0,
        'opacity': 0.7,
        'showDetailedTime': false,
        'isInfoVisible': true,
        'isObfuscated': false,
        'selectedDate': null,
      };
    }
  }

  static Future<void> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('All preferences cleared successfully');
    } catch (e) {
      print('Error clearing preferences: $e');
    }
  }
} 