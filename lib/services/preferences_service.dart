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
        final dateString = selectedDate.toIso8601String();
        await prefs.setString('selectedDate', dateString);
        print('Saved date to preferences: $dateString');
      } else {
        await prefs.remove('selectedDate');
        print('Removed date from preferences');
      }
      
      print('Preferences saved successfully: fontSize=$fontSize, opacity=$opacity');
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
      
      // Load selected date with proper error handling
      DateTime? selectedDate;
      try {
        final savedDateString = prefs.getString('selectedDate');
        print('Loaded date string from preferences: $savedDateString');
        
        if (savedDateString != null && savedDateString.isNotEmpty) {
          selectedDate = DateTime.parse(savedDateString);
          print('Successfully parsed date: ${selectedDate.toIso8601String()}');
        } else {
          print('No saved date found in preferences');
        }
      } catch (e) {
        print('Error parsing saved date: $e');
        // If there's an error parsing the date, remove the invalid value
        await prefs.remove('selectedDate');
      }

      final result = {
        'fontSize': savedFontSize ?? 18.0,
        'opacity': savedOpacity ?? 0.7,
        'showDetailedTime': savedShowDetailedTime ?? false,
        'isInfoVisible': savedIsInfoVisible ?? true,
        'isObfuscated': savedIsObfuscated ?? false,
        'selectedDate': selectedDate,
      };
      
      print('Loaded preferences: $result');
      return result;
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
      
      // Save the current language setting and date
      final languageCode = prefs.getString('language_code');
      final savedDateString = prefs.getString('selectedDate');
      
      // Clear all preferences
      await prefs.clear();
      
      // Restore the language setting if it existed
      if (languageCode != null) {
        await prefs.setString('language_code', languageCode);
        print('Language preference preserved: $languageCode');
      }
      
      // Restore the date if it existed
      if (savedDateString != null) {
        await prefs.setString('selectedDate', savedDateString);
        print('Date preference preserved: $savedDateString');
      }
      
      print('All preferences cleared successfully (except language and date)');
    } catch (e) {
      print('Error clearing preferences: $e');
    }
  }

  static Future<void> clearLanguagePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('language_code');
      print('Language preferences cleared successfully');
    } catch (e) {
      print('Error clearing language preferences: $e');
    }
  }
} 