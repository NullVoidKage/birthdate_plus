import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'language_code';
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  LanguageProvider() {
    print('LanguageProvider constructor called');
    _initializeSync();
  }

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;

  void _initializeSync() {
    _currentLocale = const Locale('en');
    _isInitialized = true;
    notifyListeners();
    print('Language provider initialized synchronously with default locale');
    
    // Then load the saved preference asynchronously
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
        print('Loaded saved language: $savedLanguage');
      }
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  Future<void> initializeAsync() async {
    if (_isInitialized) return;
    _initializeSync();
  }

  Future<void> setLanguage(String languageCode) async {
    print('Setting language to: $languageCode');
    if (_currentLocale.languageCode == languageCode) {
      print('Language is already set to $languageCode');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _currentLocale = Locale(languageCode);
      notifyListeners();
      print('Language updated to: $languageCode');
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  // Helper method to get the display name of the current language
  String getCurrentLanguageDisplayName() {
    switch (_currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'hi':
        return 'हिंदी';
      case 'pt':
        return 'Português';
      case 'zh':
        return '中文';
      case 'ko':
        return '한국어';
      case 'ja':
        return '日本語';
      default:
        return 'English';
    }
  }
} 