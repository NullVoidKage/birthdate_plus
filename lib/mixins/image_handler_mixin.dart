import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin ImageHandlerMixin<T extends StatefulWidget> on State<T> {
  File? image;
  String? imagePath;
  bool _isSaving = false;

  bool get isSaving => _isSaving;

  void setSaving(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        setState(() {
          image = imageFile;
          imagePath = pickedFile.path;
        });
        await _saveImagePath(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loadSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('image_path');
      
      if (savedImagePath != null) {
        final File imageFile = File(savedImagePath);
        if (await imageFile.exists()) {
          setState(() {
            image = imageFile;
            imagePath = savedImagePath;
          });
        } else {
          // If the file doesn't exist, remove the saved path
          await prefs.remove('image_path');
        }
      }
    } catch (e) {
      print('Error loading saved image: $e');
    }
  }

  Future<void> _saveImagePath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_path', path);
    } catch (e) {
      print('Error saving image path: $e');
    }
  }
} 