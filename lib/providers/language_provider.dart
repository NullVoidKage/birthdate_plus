import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'language_code';
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  LanguageProvider() {
    print('LanguageProvider constructor called');
    initializeAsync(); // Start initialization immediately
  }

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;

  Future<void> initializeAsync() async {
    if (_isInitialized) return; // Prevent multiple initializations

    try {
      print('Initializing language provider...');
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null && languageCode.isNotEmpty) {
        _currentLocale = Locale(languageCode);
      } else {
        _currentLocale = const Locale('en');
        await prefs.setString(_languageKey, 'en');
      }
      
      _isInitialized = true;
      notifyListeners();
      print('Language provider initialized successfully with locale: ${_currentLocale.languageCode}');
    } catch (e) {
      print('Error initializing language provider: $e');
      // Set default values in case of error
      _currentLocale = const Locale('en');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _currentLocale = Locale(languageCode);
      notifyListeners();
      print('Language changed to: $languageCode');
    } catch (e) {
      print('Error setting language: $e');
    }
  }
} 