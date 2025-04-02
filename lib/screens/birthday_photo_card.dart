import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/birthday_photo_card/birthday_app_bar.dart';
import '../widgets/birthday_photo_card/empty_state.dart';
import '../widgets/birthday_photo_card/premium_modal.dart';
import '../services/image_service.dart';
import '../services/preferences_service.dart';
import '../services/admob_service.dart';
import '../services/premium_service.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/birthday_info_panel.dart';
import '../widgets/birthday_action_buttons.dart';
import '../widgets/birthday_customization_modal.dart';
import '../viewmodels/age_calculator_viewmodel.dart';
import '../providers/language_provider.dart';

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
  Color _textColor = Colors.white;
  double _fontSize = 18.0;
  double _opacity = 0.7;
  bool _showDetailedTime = false;
  bool _isSavingMode = false;
  DateTime? _selectedDate;
  final AdMobService _adMobService = AdMobService();

  // Cake animation variables
  List<CakeAnimation> _cakes = [];
  Timer? _cakeTimer;
  bool _showCakes = false;

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

    // Start cake animation timer
    _cakeTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_showCakes && mounted) {
        setState(() {
          _updateCakes();
        });
      }
    });

    // Load saved preferences after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPreferences();
      setState(() {
        _image = null;
      });
      
      await _loadImageFromPreferences();
      
      // Preload the rewarded ad
      await _adMobService.loadRewardedAd();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cakeTimer?.cancel();
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
    if (_isSaving) return; // Prevent multiple clicks while saving
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Check if user is premium
      final isPremium = await PremiumService.isPremium();
      
      if (!isPremium) {
        // Show reward ad first
        final bool adCompleted = await _adMobService.showRewardedAd();
        
        if (!adCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please watch the ad to save your photo'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
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
                Share.shareXFiles([XFile(file.path)], text: 'Check out my birthday card!');
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
              textColor: _textColor,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              isBold: false,
              isItalic: false,
              hasShadow: false,
              isPremium: false,
              onTextColorChanged: (color) {
                setModalState(() {
                  setState(() {
                    _textColor = color;
                  });
                });
                _savePreferences();
              },
              onBackgroundColorChanged: (color) {
                setModalState(() {
                  setState(() {
                    // Add background color state handling
                  });
                });
                _savePreferences();
              },
              onBoldChanged: (value) {
                setModalState(() {
                  setState(() {
                    // Add bold state handling
                  });
                });
                _savePreferences();
              },
              onItalicChanged: (value) {
                setModalState(() {
                  setState(() {
                    // Add italic state handling
                  });
                });
                _savePreferences();
              },
              onShadowChanged: (value) {
                setModalState(() {
                  setState(() {
                    // Add shadow state handling
                  });
                });
                _savePreferences();
              },
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

  void _updateCakes() {
    _cakes.removeWhere((cake) => cake.isComplete);
    if (_cakes.length < 20 && _showCakes) {
      // Add multiple cakes at different positions
      for (int i = 0; i < 3; i++) {
        _cakes.add(CakeAnimation(
          position: Offset(
            20 + Random().nextDouble() * (MediaQuery.of(context).size.width - 40),
            MediaQuery.of(context).size.height - 150,
          ),
        ));
      }
    }
    for (var cake in _cakes) {
      cake.update();
    }
  }

  void _toggleCakes() {
    setState(() {
      _showCakes = !_showCakes;
      if (_showCakes) {
        // Add initial burst of cakes
        for (int i = 0; i < 10; i++) {
          _cakes.add(CakeAnimation(
            position: Offset(
              20 + Random().nextDouble() * (MediaQuery.of(context).size.width - 40),
              MediaQuery.of(context).size.height - 150,
            ),
          ));
        }
      } else {
        _cakes.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: BirthdayAppBar(
            showDetailedTime: _showDetailedTime,
            isObfuscated: _isObfuscated,
            isInfoVisible: _isInfoVisible,
            onTimeFormatToggle: _toggleTimeFormat,
            onCustomize: () => _showCustomizationModal(),
            onVisibilityToggle: _toggleInfoVisibility,
            onObfuscateToggle: () {
              setState(() {
                _isObfuscated = !_isObfuscated;
              });
              _savePreferences();
            },
            onResetAll: _resetAll,
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    final viewModel = Provider.of<AgeCalculatorViewModel>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5);
    final accentColor = isDarkMode ? Color(0xFFE0E0E0) : Color(0xFF333333);
    final overlayColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3);

    final ageText = _selectedDate != null 
        ? date_utils.DateUtils.calculateAgeText(context, _selectedDate!)
        : '';

    return Container(
      color: backgroundColor,
      child: GestureDetector(
        onTapDown: (details) {
          if (!_isSavingMode) {
            _toggleCakes();
          }
        },
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
                      child: FutureBuilder<bool>(
                        future: PremiumService.isPremium(),
                        builder: (context, snapshot) {
                          final isPremium = snapshot.data ?? false;
                          if (isPremium) return SizedBox.shrink();
                          
                          return FadeTransition(
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
                                  'Birthdate+',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
                    if (_showCakes) ..._cakes.map((cake) => cake.build()),
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

class CakeAnimation {
  Offset position;
  double opacity = 1.0;
  double scale = 0.0;
  bool isComplete = false;
  double rotation = 0.0;

  CakeAnimation({required this.position}) {
    rotation = Random().nextDouble() * 6.28; // Random rotation (0 to 2π)
  }

  void update() {
    position = Offset(
      position.dx + (Random().nextDouble() - 0.5) * 2, // Add slight horizontal movement
      position.dy - 4, // Move up faster
    );
    opacity = (opacity - 0.01).clamp(0.0, 1.0);
    scale = opacity;
    rotation += 0.05;
    if (opacity <= 0) isComplete = true;
  }

  Widget build() {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale.clamp(0.0, 1.0),
            child: Icon(
              Icons.cake,
              color: Colors.pink.shade200,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
} 