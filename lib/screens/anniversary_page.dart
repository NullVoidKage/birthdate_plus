import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/time_counter_card.dart';
import '../widgets/bottom_buttons.dart';
import '../mixins/image_handler_mixin.dart';
import '../utils/date_calculator.dart';
import '../widgets/relationship_stats.dart';

enum TrackingMode { Anniversary, Monthsary, TotalDays, Statistics }

class AnniversaryPage extends StatefulWidget {
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
  final GlobalKey _globalKey = GlobalKey();

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
  Color _textColor = Colors.white;
  double _fontSize = 18.0;
  double _opacity = 0.2;

  // Tracking mode
  TrackingMode _trackingMode = TrackingMode.Anniversary;

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
        _anniversaryDate = DateTime.now().subtract(Duration(days: 365));
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
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
    try {
      setState(() {
        setSaving(true);
        _takingScreenshot = true;
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
      final filePath = '${directory.path}/anniversary_card_$timestamp.png';

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
        setSaving(false);
        _takingScreenshot = false;
      });
    }
  }

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
              color: isDarkMode ? Colors.white70 : Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    if (_anniversaryDate != null) {
      _calculateDuration();
    }

    final String formattedAnniversaryDate = _anniversaryDate != null
        ? DateFormat("MMMM d, y").format(_anniversaryDate!)
        : "Select Date";

    final String dateComparisonText = _anniversaryDate != null
        ? DateCalculator.getDateComparisonText(_anniversaryDate!)
        : "Select Date";

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              title: Text(
                'Moments',
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
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.9),
                            borderRadius: BorderRadius.vertical(
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
                                        ? Icons.cake_rounded
                                        : mode == TrackingMode.Monthsary
                                            ? Icons.calendar_month_rounded
                                            : mode == TrackingMode.TotalDays
                                                ? Icons.timer_rounded
                                                : Icons.analytics_rounded,
                                    color: _trackingMode == mode
                                        ? Colors.purple.shade200
                                        : Colors.white70,
                                  ),
                                  title: Text(
                                    mode == TrackingMode.Anniversary
                                        ? 'Anniversary'
                                        : mode == TrackingMode.Monthsary
                                            ? 'Monthsary'
                                            : mode == TrackingMode.TotalDays
                                                ? 'Total Time'
                                                : 'Statistics',
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
                                leading: Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white70,
                                ),
                                title: Text(
                                  'Reset Page',
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
                                        title: Text(
                                          'Reset Page',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Text(
                                          'This will clear your image and date. Are you sure?',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Cancel',
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
                                              'Reset',
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
                SizedBox(width: 8),
              ],
            ),
      body: Container(
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
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  fit: StackFit.expand,  // Make sure Stack fills the space
                  children: [
                    // Background or image
                    _buildBackgroundImage(),
                    _buildOverlay(),
                    _buildTimeDisplay(dateComparisonText, formattedAnniversaryDate),
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
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Birthdate Plus',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!_takingScreenshot)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.calendar_today_rounded, color: Colors.white),
                                onPressed: _pickDate,
                              ),
                              IconButton(
                                icon: Icon(Icons.camera_alt_rounded, color: Colors.white),
                                onPressed: () => pickImage(ImageSource.camera),
                              ),
                              IconButton(
                                icon: Icon(Icons.photo_library_rounded, color: Colors.white),
                                onPressed: () => pickImage(ImageSource.gallery),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.save_alt_rounded,
                                  color: image != null ? Colors.white : Colors.white.withOpacity(0.3),
                                ),
                                onPressed: image != null ? _saveImage : null,
                              ),
                            ],
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

  Widget _buildBackgroundImage() {
    return image != null
        ? FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    color: Colors.grey[800]!.withOpacity(0.5),
                    child: Icon(Icons.error_outline, color: Colors.white),
                  );
                },
              ),
            ),
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 50,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select or take a photo to add your\nanniversary memories',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    return Positioned(
      bottom: 100,  // Fixed position regardless of screenshot state
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: 0.9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(24),
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
                    formattedAnniversaryDate,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_trackingMode == TrackingMode.Statistics && _anniversaryDate != null)
                    RelationshipStats(
                      anniversaryDate: _anniversaryDate!,
                      currentDate: DateTime.now(),
                    )
                  else
                    _buildTimeCounters(),
                  SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildTimeCounters() {
    if (_trackingMode == TrackingMode.TotalDays) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeCard(_years.toString(), _years == 1 ? 'Year' : 'Years'),
              _buildTimeCard(_months.toString(), _months == 1 ? 'Month' : 'Months'),
              _buildTimeCard(_totalWeeks.toString(), _totalWeeks == 1 ? 'Week' : 'Weeks'),
              _buildTimeCard(_remainingDays.toString(), _remainingDays == 1 ? 'Day' : 'Days'),
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
              _buildTimeCard(_years < 10 ? '0${_years}' : _years.toString(), _years == 1 ? 'Year' : 'Years'),
              _buildTimeCard(_months < 10 ? '0${_months}' : _months.toString(), _months == 1 ? 'Month' : 'Months'),
              _buildTimeCard(_days < 10 ? '0${_days}' : _days.toString(), _days == 1 ? 'Day' : 'Days'),
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
              _buildTimeCard(_months < 10 ? '0${_months}' : _months.toString(), _months == 1 ? 'Month' : 'Months'),
              _buildTimeCard(_days < 10 ? '0${_days}' : _days.toString(), _days == 1 ? 'Day' : 'Days'),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 4),
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
} 