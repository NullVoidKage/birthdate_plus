import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'birthday_app_bar.dart';
import 'empty_state.dart';
import 'share_options.dart';
import 'premium_modal.dart';
import '../../services/image_service.dart';
import '../../services/preferences_service.dart';
import '../../utils/date_utils.dart' as date_utils;
import '../birthday_info_panel.dart';
import '../birthday_action_buttons.dart';
import '../birthday_customization_modal.dart';
import '../../viewmodels/age_calculator_viewmodel.dart';

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
  Offset _imagePosition = Offset.zero;
  double _imageScale = 1.0;
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

  Future<void> _loadPreferences() async {
    final prefs = await PreferencesService.loadPreferences();
    setState(() {
      _fontSize = prefs['fontSize'];
      _opacity = prefs['opacity'];
      _showDetailedTime = prefs['showDetailedTime'];
      _isInfoVisible = prefs['isInfoVisible'];
      _isObfuscated = prefs['isObfuscated'];
      _selectedDate = prefs['selectedDate'];
    });
  }

  Future<void> _loadImageFromPreferences() async {
    final image = await ImageService.loadImageFromPreferences();
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImageService.pickImage(source);
      if (image != null) {
        // Clear the current image first
        setState(() {
          _image = null;
        });
        
        // Short delay to ensure UI updates
        await Future.delayed(Duration(milliseconds: 50));
        
        // Read the image file as bytes
        final Uint8List imageBytes = await image.readAsBytes();

        // Save the image to SharedPreferences
        await ImageService.saveImageToPreferences(imageBytes);

        // Update the state with the selected image
        setState(() {
          _image = image;
        });

        // Reset animation when a new image is selected
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveImage() async {
    try {
      setState(() {
        _isSaving = true;
        _isSavingMode = true;
      });

      print('Starting save process...');

      // Short delay to ensure UI updates before capture
      await Future.delayed(Duration(milliseconds: 100));

      final file = await ImageService.captureWidgetAsImage(_globalKey);
      if (file != null) {
        // Show success dialog and optionally share
        _showSuccessDialog(file);
      }
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
        _isSavingMode = false;
      });
    }
  }

  void _showSuccessDialog(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          title: Text(
            'Photo Saved',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your photo has been saved successfully',
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
                    image: FileImage(file),
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
                Navigator.of(context).pop();
                _showShareOptions(file.path);
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

  void _toggleTimeFormat() {
    setState(() {
      _showDetailedTime = !_showDetailedTime;
    });
    _savePreferences();
  }

  void _toggleInfoVisibility() {
    setState(() {
      _isInfoVisible = !_isInfoVisible;
    });
    _savePreferences();
  }

  void _handleImageScale(ScaleUpdateDetails details) {
    setState(() {
      _imageScale = (_imageScale * details.scale).clamp(0.5, 3.0);
      _imagePosition += details.focalPointDelta;
    });
  }

  void _resetImagePosition() {
    setState(() {
      _imagePosition = Offset.zero;
      _imageScale = 1.0;
    });
  }

  Future<void> _resetAll() async {
    await PreferencesService.clearAllPreferences();
    await ImageService.clearSavedImage();
    
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

  Future<void> _savePreferences() async {
    await PreferencesService.savePreferences(
      fontSize: _fontSize,
      opacity: _opacity,
      showDetailedTime: _showDetailedTime,
      isInfoVisible: _isInfoVisible,
      isObfuscated: _isObfuscated,
      selectedDate: _selectedDate,
    );
  }

  void _showShareOptions(String filePath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareOptions(
        onSave: () {
          Navigator.pop(context);
          // Implement save to gallery
        },
        onShareInstagram: () {
          Navigator.pop(context);
          // Implement Instagram sharing
        },
        onShareWhatsApp: () {
          Navigator.pop(context);
          // Implement WhatsApp sharing
        },
      ),
    );
  }

  void _showPremiumModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumModal(
        onUpgrade: () {
          Navigator.pop(context);
          // Implement premium purchase
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AgeCalculatorViewModel>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5);
    final accentColor = isDarkMode ? Color(0xFFE0E0E0) : Color(0xFF333333);
    final overlayColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3);

    final ageText = date_utils.DateUtils.calculateAgeText(_selectedDate, _isObfuscated);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BirthdayAppBar(
        showDetailedTime: _showDetailedTime,
        isObfuscated: _isObfuscated,
        isInfoVisible: _isInfoVisible,
        onTimeFormatToggle: _toggleTimeFormat,
        onCustomize: () => _showCustomizationModal(),
        onVisibilityToggle: _toggleInfoVisibility,
        onResetPosition: _resetImagePosition,
        onObfuscateToggle: () {
          setState(() {
            _isObfuscated = !_isObfuscated;
          });
          _savePreferences();
        },
        onResetAll: _resetAll,
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
                        : EmptyState(
                            onPickImage: () => _pickImage(ImageSource.gallery),
                            accentColor: accentColor,
                          ),

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