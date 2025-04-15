import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthdate_plus/l10n/app_localizations.dart';
import '../services/admob_service.dart';
import '../services/premium_service.dart';

import '../widgets/time_counter_card.dart';
import '../widgets/bottom_buttons.dart';
import '../mixins/image_handler_mixin.dart';
import '../utils/date_calculator.dart';
import '../widgets/relationship_stats.dart';

enum TrackingMode { Anniversary, Monthsary, TotalDays, Statistics }

class AnniversaryPage extends StatefulWidget {
  const AnniversaryPage({super.key});

  @override
  _AnniversaryPageState createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends State<AnniversaryPage>
    with SingleTickerProviderStateMixin, ImageHandlerMixin {
  DateTime? _anniversaryDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _takingScreenshot = false;
  bool _isSaving = false;
  final GlobalKey _globalKey = GlobalKey();
  final AdMobService _adMobService = AdMobService();

  // Duration calculation variables
  int _years = 0;
  int _months = 0;
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  // Total time variables
  int _totalDays = 0;
  int _totalWeeks = 0;
  int _remainingDays = 0;

  // Text style customization
  final Color _textColor = Colors.white;
  final double _fontSize = 18.0;
  final double _opacity = 0.2;

  // Tracking mode
  TrackingMode _trackingMode = TrackingMode.Anniversary;

  // Heart animation variables
  final List<HeartAnimation> _hearts = [];
  Timer? _heartTimer;
  bool _showHearts = false;

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

    _loadSavedData().then((_) {
      if (image != null) {
        _animationController.forward();
      }
    });

    _startTimer();

    // Start heart animation timer
    _heartTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_showHearts && mounted) {
        setState(() {
          _updateHearts();
        });
      }
    });

    // Preload the rewarded ad
    _adMobService.loadRewardedAd();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDateMillis = prefs.getInt('anniversary_date');
    if (savedDateMillis != null) {
      setState(() {
        _anniversaryDate = DateTime.fromMillisecondsSinceEpoch(savedDateMillis);
      });
    } else {
      setState(() {
        final now = DateTime.now();
        _anniversaryDate = DateTime(now.year, now.month - 1, now.day);
      });
    }

    final savedTrackingMode = prefs.getInt('tracking_mode');
    if (savedTrackingMode != null) {
      setState(() {
        _trackingMode = TrackingMode.values[savedTrackingMode];
      });
    }

    await loadSavedImage();
    _calculateDuration();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    if (_anniversaryDate != null) {
      await prefs.setInt(
          'anniversary_date', _anniversaryDate!.millisecondsSinceEpoch);
    }

    await prefs.setInt('tracking_mode', _trackingMode.index);

    if (imagePath != null) {
      await prefs.setString('image_path', imagePath!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _heartTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateDuration();
      }
    });
  }

  void _calculateDuration() {
    if (_anniversaryDate == null) return;

    final duration = DateCalculator.calculateDuration(_anniversaryDate!);
    
    setState(() {
      _years = duration['years']!;
      _months = duration['months']!;
      _days = duration['days']!;
      _totalDays = duration['totalDays']!;
      _totalWeeks = duration['totalWeeks']!;
      _remainingDays = duration['remainingDays']!;

      final now = DateTime.now();
      final remaining = now.difference(DateTime(now.year, now.month, now.day));
      _hours = remaining.inHours;
      _minutes = remaining.inMinutes % 60;
      _seconds = remaining.inSeconds % 60;
    });
  }

  void _toggleTrackingMode(TrackingMode mode) {
    setState(() {
      _trackingMode = mode;
    });
    _saveData();
    _calculateDuration();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _anniversaryDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.pink.shade300,
              onPrimary: Colors.white,
              surface: Colors.pink.shade900,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _anniversaryDate) {
      setState(() {
        _anniversaryDate = picked;
      });
      _calculateDuration();
      await _saveData();
      setState(() {});
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
            const SnackBar(
              content: Text('Please watch the ad to save your anniversary card'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        setSaving(true);
        _takingScreenshot = true;
      });

      print('Starting save process...');

      // Short delay to ensure UI updates before capture
      await Future.delayed(const Duration(milliseconds: 100));

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
      final filePath = '${directory.path}/anniversary_card_$timestamp.png';

      // Create and write to file
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Show success dialog and optionally share
      _showSuccessDialog(file);

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
        _takingScreenshot = false;
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
              const SizedBox(height: 16),
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
                Share.shareXFiles([XFile(file.path)],
                    text: 'Check out my anniversary card!');
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

  void _updateHearts() {
    _hearts.removeWhere((heart) => heart.isComplete);
    if (_hearts.length < 20 && _showHearts) {
      // Add multiple hearts at different positions
      for (int i = 0; i < 3; i++) {
        _hearts.add(HeartAnimation(
          position: Offset(
            20 + Random().nextDouble() * (MediaQuery.of(context).size.width - 40),
            MediaQuery.of(context).size.height - 150,
          ),
        ));
      }
    }
    for (var heart in _hearts) {
      heart.update();
    }
  }

  void _toggleHearts() {
    setState(() {
      _showHearts = !_showHearts;
      if (_showHearts) {
        // Add initial burst of hearts
        for (int i = 0; i < 10; i++) {
          _hearts.add(HeartAnimation(
            position: Offset(
              20 + Random().nextDouble() * (MediaQuery.of(context).size.width - 40),
              MediaQuery.of(context).size.height - 150,
            ),
          ));
        }
      } else {
        _hearts.clear();
      }
    });
  }

  Future<void> _shareWithTemplate() async {
    if (_isSaving) return; // Prevent multiple clicks while sharing
    
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
            const SnackBar(
              content: Text('Please watch the ad to share your anniversary card'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        _takingScreenshot = true;
      });

      // Short delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to capture image');
      }

      final pngBytes = byteData.buffer.asUint8List();
      
      // Save and share with classic template directly
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/anniversary_classic_$timestamp.png';
      
      // Save processed image
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Share with custom message
      String message = 'Celebrating $_years years';
      if (_years == 0) {
        message = 'Celebrating $_months months and $_days days';
      }
      message += ' of love! 💑\n#CoupleGoals #Love #Anniversary';
      
      Share.shareXFiles(
        [XFile(filePath)],
        text: message,
      );
    } catch (e) {
      print('Error sharing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
        _takingScreenshot = false;
      });
    }
  }

  Future<void> _saveImagePath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_path', path);
      print('Saved image path to preferences: $path');
    } catch (e) {
      print('Error saving image path: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback to English strings if localization is not available
      final String formattedAnniversaryDate = _anniversaryDate != null
          ? DateFormat("MMMM d, y").format(_anniversaryDate!)
          : "Birth Date";
      
      final String formattedCurrentDate = DateFormat("MMMM d, y").format(DateTime.now());
      
      final String displayDate = _anniversaryDate != null
          ? "$formattedAnniversaryDate - $formattedCurrentDate"
          : "Birth Date";

      final String dateComparisonText = _anniversaryDate != null
          ? DateCalculator.getDateComparisonText(_anniversaryDate!)
          : "Birth Date";

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _takingScreenshot
            ? null
            : AppBar(
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                title: Text(
                  "Anniversary Cards",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    letterSpacing: 0.5,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.white,
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.9),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...TrackingMode.values.map((mode) {
                                  return ListTile(
                                    leading: Icon(
                                      mode == TrackingMode.Anniversary
                                          ? Icons.favorite_rounded
                                          : mode == TrackingMode.Monthsary
                                              ? Icons.favorite_border_rounded
                                              : mode == TrackingMode.TotalDays
                                                  ? Icons.timer_rounded
                                                  : Icons.analytics_rounded,
                                      color: _trackingMode == mode
                                          ? Colors.purple.shade200
                                          : Colors.white70,
                                    ),
                                    title: Text(
                                      mode == TrackingMode.Anniversary
                                          ? "Anniversary Cards"
                                          : mode == TrackingMode.Monthsary
                                              ? "Months"
                                              : mode == TrackingMode.TotalDays
                                                  ? "Days"
                                                  : "Settings",
                                      style: TextStyle(
                                        color: _trackingMode == mode
                                            ? Colors.purple.shade200
                                            : Colors.white70,
                                      ),
                                    ),
                                    onTap: () {
                                      _toggleTrackingMode(mode);
                                      Navigator.pop(context);
                                    },
                                    selected: _trackingMode == mode,
                                    selectedTileColor: Colors.purple.withOpacity(0.1),
                                  );
                                }).toList(),
                                Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  thickness: 1,
                                  height: 1,
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white70,
                                  ),
                                  title: const Text(
                                    "Settings",
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.grey[850],
                                          title: const Text(
                                            "Settings",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          content: const Text(
                                            "Discover Facts",
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Settings",
                                                style: TextStyle(color: Colors.white70),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                final prefs = await SharedPreferences.getInstance();
                                                await prefs.remove('anniversary_date');
                                                await prefs.remove('image_path');
                                                setState(() {
                                                  _anniversaryDate = null;
                                                  image = null;
                                                  imagePath = null;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Settings",
                                                style: TextStyle(color: Colors.red[300]),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        body: GestureDetector(
          onTapDown: (details) {
            if (!_takingScreenshot) {
              _toggleHearts();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[800]!.withOpacity(0.5),
                  Colors.grey[700]!.withOpacity(0.4),
                  Colors.grey[600]!.withOpacity(0.5),
                ],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildBackgroundImage(),
                            _buildOverlay(),
                            _buildTimeDisplay(dateComparisonText, formattedAnniversaryDate),
                            if (_showHearts) ..._hearts.map((heart) => heart.build()),
                            FutureBuilder<bool>(
                              future: PremiumService.isPremium(),
                              builder: (context, snapshot) {
                                final isPremium = snapshot.data ?? false;
                                if (isPremium) return const SizedBox.shrink();
                                
                                return Positioned(
                                  top: 150,
                                  right: 20,
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        "Birthdate Plus",
                                        style: TextStyle(
                                          color: Colors.white,
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (!_takingScreenshot)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.white),
                          onPressed: _pickDate,
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () => pickImage(ImageSource.camera),
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_library, color: Colors.white),
                          onPressed: () => pickImage(ImageSource.gallery),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: _shareWithTemplate,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (_anniversaryDate != null) {
      _calculateDuration();
    }

    final String formattedAnniversaryDate = _anniversaryDate != null
        ? DateFormat("MMMM d, y").format(_anniversaryDate!)
        : l10n.birthDate;
    
    final String formattedCurrentDate = DateFormat("MMMM d, y").format(DateTime.now());
    
    final String displayDate = _anniversaryDate != null
        ? "$formattedAnniversaryDate - $formattedCurrentDate"
        : l10n.birthDate;

    final String dateComparisonText = _anniversaryDate != null
        ? DateCalculator.getDateComparisonText(_anniversaryDate!)
        : l10n.birthDate;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _takingScreenshot
          ? null
          : AppBar(
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              title: Text(
                l10n.anniversaryCards,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  letterSpacing: 0.5,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.white,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.9),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...TrackingMode.values.map((mode) {
                                return ListTile(
                                  leading: Icon(
                                    mode == TrackingMode.Anniversary
                                        ? Icons.favorite_rounded
                                        : mode == TrackingMode.Monthsary
                                            ? Icons.favorite_border_rounded
                                            : mode == TrackingMode.TotalDays
                                                ? Icons.timer_rounded
                                                : Icons.analytics_rounded,
                                    color: _trackingMode == mode
                                        ? Colors.purple.shade200
                                        : Colors.white70,
                                  ),
                                  title: Text(
                                    mode == TrackingMode.Anniversary
                                        ? l10n.anniversaryCards
                                        : mode == TrackingMode.Monthsary
                                            ? l10n.months
                                            : mode == TrackingMode.TotalDays
                                                ? l10n.days
                                                : l10n.settings,
                                    style: TextStyle(
                                      color: _trackingMode == mode
                                          ? Colors.purple.shade200
                                          : Colors.white70,
                                    ),
                                  ),
                                  onTap: () {
                                    _toggleTrackingMode(mode);
                                    Navigator.pop(context);
                                  },
                                  selected: _trackingMode == mode,
                                  selectedTileColor: Colors.purple.withOpacity(0.1),
                                );
                              }).toList(),
                              Divider(
                                color: Colors.white.withOpacity(0.1),
                                thickness: 1,
                                height: 1,
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white70,
                                ),
                                title: Text(
                                  l10n.settings,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.grey[850],
                                        title: Text(
                                          l10n.settings,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        content: Text(
                                          l10n.discoverFacts,
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              l10n.settings,
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.remove('anniversary_date');
                                              await prefs.remove('image_path');
                                              setState(() {
                                                _anniversaryDate = null;
                                                image = null;
                                                imagePath = null;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              l10n.settings,
                                              style: TextStyle(color: Colors.red[300]),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: GestureDetector(
        onTapDown: (details) {
          if (!_takingScreenshot) {
            _toggleHearts();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[800]!.withOpacity(0.5),
                Colors.grey[700]!.withOpacity(0.4),
                Colors.grey[600]!.withOpacity(0.5),
              ],
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildBackgroundImage(),
                          _buildOverlay(),
                          _buildTimeDisplay(dateComparisonText, formattedAnniversaryDate),
                          if (_showHearts) ..._hearts.map((heart) => heart.build()),
                          FutureBuilder<bool>(
                            future: PremiumService.isPremium(),
                            builder: (context, snapshot) {
                              final isPremium = snapshot.data ?? false;
                              if (isPremium) return const SizedBox.shrink();
                              
                              return Positioned(
                                top: 150,
                                right: 20,
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      l10n.appTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              if (!_takingScreenshot)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.white),
                        onPressed: _pickDate,
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () => pickImage(ImageSource.camera),
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        onPressed: () => pickImage(ImageSource.gallery),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: _shareWithTemplate,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return image != null
        ? FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    color: Colors.grey[800]!.withOpacity(0.5),
                    child: const Icon(Icons.error_outline, color: Colors.white),
                  );
                },
              ),
            ),
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2B2B3D),
                  Color(0xFF1A1A2E),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 32,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context);
                                    if (l10n == null) {
                                      return Column(
                                        children: [
                                          Text(
                                            "Capture Moments",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 24,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Add photos to create beautiful anniversary cards",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.6),
                                              fontSize: 14,
                                              height: 1.5,
                                              letterSpacing: 0.3,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        Text(
                                          l10n.captureMoments,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          l10n.addPhotosDescription,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 14,
                                            height: 1.5,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _anniversaryDate != null
                                      ? "${DateFormat("MMMM d, y").format(_anniversaryDate!)} - ${DateFormat("MMMM d, y").format(DateTime.now())}"
                                      : "Select Date",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildTimeUnit('01', 'Year'),
                                      _buildTimeUnit('00', 'Months'),
                                      _buildTimeUnit('00', 'Days'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Builder(
                                    builder: (context) {
                                      final l10n = AppLocalizations.of(context);
                                      if (l10n == null) {
                                        return Text(
                                          "0 years and 365 days",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            letterSpacing: 0.3,
                                          ),
                                        );
                                      }
                                      return Text(
                                        l10n.yearsAndDays(0, 365),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0.3,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => pickImage(ImageSource.gallery),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context);
                                    if (l10n == null) {
                                      return Text(
                                        "Choose Photo",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.3,
                                        ),
                                      );
                                    }
                                    return Text(
                                      l10n.choosePhoto,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.3,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildOverlay() {
    return image != null
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget _buildTimeDisplay(String dateComparisonText, String formattedAnniversaryDate) {
    // Only show the overlay time display when there's an image
    if (image == null) return Container();

    final String formattedCurrentDate = DateFormat("MMMM d, y").format(DateTime.now());
    final String displayDate = "$formattedAnniversaryDate - $formattedCurrentDate";

    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: FutureBuilder<bool>(
        future: PremiumService.isPremium(),
        builder: (context, snapshot) {
          final isPremium = snapshot.data ?? false;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 0.9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_trackingMode == TrackingMode.Statistics && _anniversaryDate != null)
                        RelationshipStats(
                          anniversaryDate: _anniversaryDate!,
                          currentDate: DateTime.now(),
                        )
                      else
                        _buildTimeCounters(),
                      const SizedBox(height: 8),
                      Text(
                        dateComparisonText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.3,
                        ),
                      ),
                 
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeCounters() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback to English strings if localization is not available
      if (_trackingMode == TrackingMode.TotalDays) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeCard(_years.toString(), _years == 1 ? "Year" : "Years"),
                _buildTimeCard(_months.toString(), _months == 1 ? "Month" : "Months"),
                _buildTimeCard(_totalWeeks.toString(), _totalWeeks == 1 ? "Week" : "Weeks"),
                _buildTimeCard(_remainingDays.toString(), _remainingDays == 1 ? "Day" : "Days"),
              ],
            ),
          ],
        );
      } else if (_trackingMode == TrackingMode.Anniversary) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeCard(_years < 10 ? '0$_years' : _years.toString(), _years == 1 ? "Year" : "Years"),
                _buildTimeCard(_months < 10 ? '0$_months' : _months.toString(), _months == 1 ? "Month" : "Months"),
                _buildTimeCard(_days < 10 ? '0$_days' : _days.toString(), _days == 1 ? "Day" : "Days"),
              ],
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeCard(_months < 10 ? '0$_months' : _months.toString(), _months == 1 ? "Month" : "Months"),
                _buildTimeCard(_days < 10 ? '0$_days' : _days.toString(), _days == 1 ? "Day" : "Days"),
              ],
            ),
          ],
        );
      }
    }

    if (_trackingMode == TrackingMode.TotalDays) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeCard(_years.toString(), _years == 1 ? l10n.years : l10n.years),
              _buildTimeCard(_months.toString(), _months == 1 ? l10n.months : l10n.months),
              _buildTimeCard(_totalWeeks.toString(), _totalWeeks == 1 ? l10n.week : l10n.weeks),
              _buildTimeCard(_remainingDays.toString(), _remainingDays == 1 ? l10n.days : l10n.days),
            ],
          ),
        ],
      );
    } else if (_trackingMode == TrackingMode.Anniversary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeCard(_years < 10 ? '0$_years' : _years.toString(), _years == 1 ? l10n.years : l10n.years),
              _buildTimeCard(_months < 10 ? '0$_months' : _months.toString(), _months == 1 ? l10n.months : l10n.months),
              _buildTimeCard(_days < 10 ? '0$_days' : _days.toString(), _days == 1 ? l10n.days : l10n.days),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeCard(_months < 10 ? '0$_months' : _months.toString(), _months == 1 ? l10n.months : l10n.months),
              _buildTimeCard(_days < 10 ? '0$_days' : _days.toString(), _days == 1 ? l10n.days : l10n.days),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTimeCard(String value, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  @override
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
        // Get the app's local storage directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'saved_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImagePath = '${appDir.path}/$fileName';

        // Copy the picked image to app's local storage
        final File imageFile = File(pickedFile.path);
        final File savedImage = await imageFile.copy(savedImagePath);

        // Update state first
        setState(() {
          image = savedImage;
          imagePath = savedImagePath;
        });

        // Save the permanent image path to SharedPreferences
        await _saveImagePath(savedImagePath);

        // Reset animation and forward it
        if (mounted) {
          _animationController.reset();
          _animationController.forward();
        }
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
}

class HeartAnimation {
  Offset position;
  double opacity = 1.0;
  double scale = 0.0;
  bool isComplete = false;
  double rotation = 0.0;

  HeartAnimation({required this.position}) {
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
              Icons.favorite,
              color: Colors.pink.shade200,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
} 