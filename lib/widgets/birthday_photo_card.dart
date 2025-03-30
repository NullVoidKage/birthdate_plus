import 'dart:convert';
import 'dart:io';

import 'package:birthdate_plus/viewmodels/age_calculator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/birthday_info_panel.dart';
import '../widgets/birthday_action_buttons.dart';
import '../widgets/birthday_customization_modal.dart';
import '../services/birthday_service.dart';

class BirthdayPhotoCard extends StatefulWidget {
  @override
  _BirthdayPhotoCardState createState() => _BirthdayPhotoCardState();
}

class _BirthdayPhotoCardState extends State<BirthdayPhotoCard>
    with SingleTickerProviderStateMixin {
  File? _image;
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSaving = false;
  bool _isInfoVisible = true;
  bool _isObfuscated = false;
  // Add position tracking variables
  Offset _imagePosition = Offset.zero;
  double _imageScale = 1.0;
  // Text style customization
  Color _textColor = Colors.white;
  double _fontSize = 18.0;
  double _opacity = 0.7;
  bool _showDetailedTime = false;
  bool _isSavingMode = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();

    // Load saved preferences after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPreferences();
      setState(() {
        _image = null;
      });
      
      await _loadImageFromPreferences();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        // Clear the current image first
        setState(() {
          _image = null;
        });
        
        // Short delay to ensure UI updates
        await Future.delayed(Duration(milliseconds: 50));
        
        // Read the image file as bytes
        final Uint8List imageBytes = await File(pickedFile.path).readAsBytes();

        // Save the image to SharedPreferences
        await _saveImageToPreferences(imageBytes);

        // Update the state with the selected image
        setState(() {
          _image = File(pickedFile.path);
        });

        // Reset animation when a new image is selected
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      // Error handling code...
    }
  }

  // Add this method to save the image to SharedPreferences
  Future<void> _saveImageToPreferences(Uint8List imageBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear any existing image data first
      await prefs.remove('savedImage');
      
      // Convert Uint8List to base64 string for storage
      final String base64Image = base64Encode(imageBytes);
      
      // Save the image as a base64 encoded string
      await prefs.setString('savedImage', base64Image);
      
      // Print the length of saved data to help with debugging
      print('Image saved to SharedPreferences: ${base64Image.length} characters');
    } catch (e) {
      print('Error saving image to SharedPreferences: $e');
      // Error handling...
    }
  }

  Future<void> _loadImageFromPreferences() async {
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
          // Update the state with the loaded image
          setState(() {
            _image = tempFile;
          });
          print('Image loaded from SharedPreferences successfully: ${tempFile.path}');
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
  }

  Future<void> _saveImage() async {
    try {
      setState(() {
        _isSaving = true;
        _isSavingMode = true; // Enter saving mode
      });

      print('Starting save process...');

      // Short delay to ensure UI updates before capture
      await Future.delayed(Duration(milliseconds: 100));

      // Get the RenderRepaintBoundary object
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

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

      // Show success dialog and optionally share
      _showSuccessDialog(filePath, pngBytes);

      print('Image saved successfully at $filePath');
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
        _isSavingMode = false; // Exit saving mode
      });
    }
  }

  void _toggleTimeFormat() {
    setState(() {
      _showDetailedTime = !_showDetailedTime;
    });
    _savePreferences();
  }

  // Add this method to get detailed time statistics
  Map<String, String> _getDetailedTimeStats(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);

    final format = NumberFormat("#,###"); // Adds comma as thousands separator

    // Calculate various time units
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds;

    // Calculate weeks and months (approximate)
    final weeks = (days / 7).floor();
    final months = (days / 30.44).floor(); // Average days per month
    final years = (days / 365.25).floor(); // Account for leap years

    return {
      'Years': format.format(years),
      'Months': format.format(months),
      'Weeks': format.format(weeks),
      'Days': format.format(days),
      'Hours': format.format(hours),
      'Minutes': format.format(minutes),
      'Seconds': format.format(seconds),
    };
  }

  void _toggleInfoVisibility() {
    setState(() {
      _isInfoVisible = !_isInfoVisible;
    });
    _savePreferences();
  }

  String _getObfuscatedText(String text) {
    return text.replaceAll(RegExp(r'\d'), '*');
  }

  // Success dialog to show after saving
  void _showSuccessDialog(String filePath, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          title: Text(
            'Image Saved',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your image has been saved successfully',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(imageBytes),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.purple.shade200
                      : Colors.purple.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Share.shareXFiles([XFile(filePath)],
                    text: 'Check out my age stats!');
              },
              child: Text(
                'Share',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.purple.shade200
                      : Colors.purple.shade700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getBirthstone(int month) {
    const birthstones = [
      'Garnet',
      'Amethyst',
      'Aquamarine',
      'Diamond',
      'Emerald',
      'Pearl',
      'Ruby',
      'Peridot',
      'Sapphire',
      'Opal',
      'Topaz',
      'Turquoise'
    ];
    return birthstones[month - 1];
  }

  String _getBirthFlower(int month) {
    const birthFlowers = [
      'Carnation',
      'Violet',
      'Daffodil',
      'Daisy',
      'Lily of the Valley',
      'Rose',
      'Larkspur',
      'Gladiolus',
      'Aster',
      'Marigold',
      'Chrysanthemum',
      'Poinsettia'
    ];
    return birthFlowers[month - 1];
  }

  String _getChineseZodiac(int year) {
    const zodiacs = [
      'Monkey',
      'Rooster',
      'Dog',
      'Pig',
      'Rat',
      'Ox',
      'Tiger',
      'Rabbit',
      'Dragon',
      'Snake',
      'Horse',
      'Goat'
    ];
    return zodiacs[year % 12];
  }

  int _getLuckyNumber(DateTime birthDate) {
    int sum = birthDate.year + birthDate.month + birthDate.day;
    while (sum >= 10) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  String _getGeneration(int year) {
    if (year >= 2025) return 'Generation Beta';  // Emerging generation
    if (year >= 2010) return 'Generation Alpha';
    if (year >= 1997) return 'Gen Z';
    if (year >= 1981) return 'Millennial';
    if (year >= 1965) return 'Gen X';
    if (year >= 1946) return 'Baby Boomer';
    return 'Silent Generation';
  }

  void _showCustomizationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return BirthdayCustomizationModal(
              fontSize: _fontSize,
              opacity: _opacity,
              onFontSizeChanged: (value) {
                setModalState(() {
                  setState(() {
                    _fontSize = value;
                  });
                });
                _savePreferences();
              },
              onOpacityChanged: (value) {
                setModalState(() {
                  setState(() {
                    _opacity = value.clamp(0.3, 0.9);
                  });
                });
                _savePreferences();
              },
              onSavePreferences: _savePreferences,
            );
          },
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save text customization settings
      await prefs.setDouble('fontSize', _fontSize);
      await prefs.setDouble('opacity', _opacity);
      await prefs.setBool('showDetailedTime', _showDetailedTime);
      await prefs.setBool('isInfoVisible', _isInfoVisible);
      await prefs.setBool('isObfuscated', _isObfuscated);
      
      // Save selected date
      if (_selectedDate != null) {
        await prefs.setString('selectedDate', _selectedDate!.toIso8601String());
      }
      
      print('Preferences saved successfully: fontSize=$_fontSize, opacity=$_opacity, date=${_selectedDate?.toIso8601String()}');
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  Future<void> _loadPreferences() async {
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
      if (savedDateString != null) {
        _selectedDate = DateTime.parse(savedDateString);
      }
      
      setState(() {
        _fontSize = savedFontSize ?? 18.0;
        _opacity = savedOpacity ?? 0.7;
        _showDetailedTime = savedShowDetailedTime ?? false;
        _isInfoVisible = savedIsInfoVisible ?? true;
        _isObfuscated = savedIsObfuscated ?? false;
      });

      print('Preferences loaded successfully: fontSize=$_fontSize, opacity=$_opacity, date=${_selectedDate?.toIso8601String()}');
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  String _calculateAgeText(DateTime? birthDate) {
    if (birthDate == null) return '';
    
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return 'Invalid date';
    
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    // Adjust for negative days
    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month - 1, 0).day;
    }

    // Adjust for negative months
    if (months < 0) {
      years--;
      months += 12;
    }

    // Format the date
    final dateFormatter = DateFormat('MMMM d, yyyy');
    String formattedDate = dateFormatter.format(birthDate);

    // Obfuscate the text if enabled
    if (_isObfuscated) {
      formattedDate = formattedDate.replaceAll(RegExp(r'\d'), '*');
    }

    // Format the output
    if (years == 0) {
      if (months == 0) {
        return '$days days old - $formattedDate';
      }
      return '$months months, $days days - $formattedDate';
    }
    
    return '${_isObfuscated ? '**' : years} y/o - $formattedDate';
  }

  Widget _infoItem(String label, String value,
      {bool isCustomFormat = false, String? customValue}) {
    if (isCustomFormat && label == 'Birthstone' && customValue != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _textColor.withOpacity(0.7),
              fontSize: _fontSize - 4,
            ),
          ),
          Text(
            customValue,
            style: TextStyle(
              color: _textColor,
              fontSize: _fontSize - 2, // Slightly smaller to fit more text
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black54,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      );
    } else {
      // Original format for other items
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _textColor.withOpacity(0.7),
              fontSize: _fontSize - 4,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _textColor,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black54,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Add method to handle image drag and scale
  void _handleImageScale(ScaleUpdateDetails details) {
    setState(() {
      // Handle scaling
      _imageScale = (_imageScale * details.scale).clamp(0.5, 3.0);
      // Handle panning
      _imagePosition += details.focalPointDelta;
    });
  }

  // Add method to reset image position
  void _resetImagePosition() {
    setState(() {
      _imagePosition = Offset.zero;
      _imageScale = 1.0;
    });
  }

  // Add reset method
  Future<void> _resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all preferences
    
    setState(() {
      _image = null;
      _selectedDate = null;
      _fontSize = 18.0;
      _opacity = 0.7;
      _showDetailedTime = false;
      _isInfoVisible = true;
      _isObfuscated = false;
      _imagePosition = Offset.zero;
      _imageScale = 1.0;
    });
  }

  Future<void> _showImageSourcePicker() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(
                  'Select Image Source',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: Colors.white),
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color accentColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.8),
                  Colors.blue.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Create Your Birthday Card',
            style: TextStyle(
              color: accentColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Add a photo and select your birthdate to discover fascinating facts about your special day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accentColor.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 40),
          // Button with gradient background
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple,
                  Colors.blue,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _showImageSourcePicker,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Choose a Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AgeCalculatorViewModel>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Modern color scheme
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5);
    final accentColor = isDarkMode ? Color(0xFFE0E0E0) : Color(0xFF333333);
    final overlayColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3);

    // Calculate age text from selected date
    final ageText = _calculateAgeText(_selectedDate);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
                      _showDetailedTime ? Icons.timer_outlined : Icons.calendar_today_outlined,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      _showDetailedTime ? 'Show Age' : 'Show Time Details',
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
                      _isObfuscated ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      _isObfuscated ? 'Show Numbers' : 'Hide Numbers',
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
                      _isInfoVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      _isInfoVisible ? 'Hide Info' : 'Show Info',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'reset_position',
                  child: ListTile(
                    leading: Icon(
                      Icons.refresh_outlined,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Reset Image Position',
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
                    _toggleTimeFormat();
                    break;
                  case 'customize':
                    _showCustomizationModal();
                    break;
                  case 'visibility':
                    _toggleInfoVisibility();
                    break;
                  case 'reset_position':
                    _resetImagePosition();
                    break;
                  case 'obfuscate':
                    setState(() {
                      _isObfuscated = !_isObfuscated;
                    });
                    _savePreferences();
                    break;
                  case 'reset_all':
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          'Reset Everything?',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'This will clear your image, date, and all customizations.',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple, Colors.blue],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _resetAll();
                              },
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    break;
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  children: [
                    // Background or image
                    _image != null
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: GestureDetector(
                              onScaleUpdate: _handleImageScale,
                              child: Transform.translate(
                                offset: _imagePosition,
                                child: Transform.scale(
                                  scale: _imageScale,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : _buildEmptyState(accentColor),

                    // Bottom info panel with modern design
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: BirthdayInfoPanel(
                        fontSize: _fontSize,
                        textColor: _textColor,
                        opacity: _opacity,
                        showDetailedTime: _showDetailedTime,
                        isInfoVisible: _isInfoVisible,
                        selectedDate: _selectedDate,
                        ageText: ageText,
                      ),
                    ),

                    // Right side text
                    Positioned(
                      top: 150,
                      right: 20,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: overlayColor,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: accentColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Birthdate Plus',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (!_isSavingMode)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: BirthdayActionButtons(
                            onPickImage: _pickImage,
                            onSave: _saveImage,
                            hasImage: _image != null,
                            selectedDate: _selectedDate,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                              _savePreferences();
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}