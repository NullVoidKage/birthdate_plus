import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageService {
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

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
        
        // Ensure the directory exists
        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }
        
        // Create a unique filename
        final tempPath = '${appDir.path}/saved_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final tempFile = File(tempPath);
        
        // Write bytes to the file
        await tempFile.writeAsBytes(imageBytes);
        
        // Verify the file exists and is readable
        if (await tempFile.exists()) {
          print('Image loaded from SharedPreferences successfully: ${tempFile.path}');
          return tempFile;
        } else {
          print('Failed to create image file at: ${tempFile.path}');
          // Clear the saved image from preferences if file creation failed
          await prefs.remove('savedImage');
        }
      } else {
        print('No saved image found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading image from SharedPreferences: $e');
      // Clear the saved image from preferences if there was an error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('savedImage');
    }
    return null;
  }

  static Future<File?> captureWidgetAsImage(GlobalKey globalKey) async {
    try {
      // Get the RenderRepaintBoundary object
      RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Convert the boundary to an image
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to capture image');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Get application documents directory for permanent storage
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/birthdate_overlay_$timestamp.png';

      // Create and write to file
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      print('Image saved successfully at $filePath');
      return file;
    } catch (e) {
      print('Error capturing widget as image: $e');
      return null;
    }
  }

  static Future<void> clearSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('savedImage');
      print('Saved image cleared from SharedPreferences');
    } catch (e) {
      print('Error clearing saved image: $e');
    }
  }
} 