import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BirthdayService {
  static Future<void> saveImageToPreferences(Uint8List imageBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear any existing image data first
      await prefs.remove('savedImage');
      
      // Convert Uint8List to base64 string for storage
      final String base64Image = base64Encode(imageBytes);
      
      // Save the image as a base64 encoded string
      await prefs.setString('savedImage', base64Image);
      
      print('Image saved to SharedPreferences: ${base64Image.length} characters');
    } catch (e) {
      print('Error saving image to SharedPreferences: $e');
      rethrow;
    }
  }

  static Future<File?> loadImageFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the saved image string
      final String? base64Image = prefs.getString('savedImage');
      print('Loading image from SharedPreferences: ${base64Image?.length ?? 0} characters');
      
      if (base64Image != null && base64Image.isNotEmpty) {
        // Convert base64 string back to Uint8List
        final Uint8List imageBytes = base64Decode(base64Image);
        
        // Create a file in application documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final tempPath = '${appDir.path}/saved_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final tempFile = File(tempPath);
        
        // Write bytes to the file
        await tempFile.writeAsBytes(imageBytes);
        
        print('Image loaded from SharedPreferences successfully: ${tempFile.path}');
        return tempFile;
      } else {
        print('No saved image found in SharedPreferences');
        return null;
      }
    } catch (e) {
      print('Error loading image from SharedPreferences: $e');
      return null;
    }
  }

  static Future<void> savePreferences({
    required double fontSize,
    required double opacity,
    required bool showDetailedTime,
    required bool isInfoVisible,
    DateTime? selectedDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save text customization settings
      await prefs.setDouble('fontSize', fontSize);
      await prefs.setDouble('opacity', opacity);
      await prefs.setBool('showDetailedTime', showDetailedTime);
      await prefs.setBool('isInfoVisible', isInfoVisible);
      
      // Save selected date
      if (selectedDate != null) {
        await prefs.setString('selectedDate', selectedDate.toIso8601String());
      }
      
      print('Preferences saved successfully: fontSize=$fontSize, opacity=$opacity, date=${selectedDate?.toIso8601String()}');
    } catch (e) {
      print('Error saving preferences: $e');
      rethrow;
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
      
      // Load selected date
      final savedDateString = prefs.getString('selectedDate');
      DateTime? selectedDate;
      if (savedDateString != null) {
        selectedDate = DateTime.parse(savedDateString);
      }
      
      return {
        'fontSize': savedFontSize ?? 18.0,
        'opacity': savedOpacity ?? 0.7,
        'showDetailedTime': savedShowDetailedTime ?? false,
        'isInfoVisible': savedIsInfoVisible ?? true,
        'selectedDate': selectedDate,
      };
    } catch (e) {
      print('Error loading preferences: $e');
      return {
        'fontSize': 18.0,
        'opacity': 0.7,
        'showDetailedTime': false,
        'isInfoVisible': true,
        'selectedDate': null,
      };
    }
  }
} 