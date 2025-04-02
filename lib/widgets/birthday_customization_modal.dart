import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BirthdayCustomizationModal extends StatelessWidget {
  final double fontSize;
  final double opacity;
  final Color textColor;
  final Color backgroundColor;
  final bool isBold;
  final bool isItalic;
  final bool hasShadow;
  final bool isPremium;
  final Function(double) onFontSizeChanged;
  final Function(double) onOpacityChanged;
  final Function(Color) onTextColorChanged;
  final Function(Color) onBackgroundColorChanged;
  final Function(bool) onBoldChanged;
  final Function(bool) onItalicChanged;
  final Function(bool) onShadowChanged;
  final VoidCallback onSavePreferences;
  final VoidCallback? onPremiumPressed;

  const BirthdayCustomizationModal({
    Key? key,
    required this.fontSize,
    required this.opacity,
    required this.textColor,
    required this.backgroundColor,
    required this.isBold,
    required this.isItalic,
    required this.hasShadow,
    required this.isPremium,
    required this.onFontSizeChanged,
    required this.onOpacityChanged,
    required this.onTextColorChanged,
    required this.onBackgroundColorChanged,
    required this.onBoldChanged,
    required this.onItalicChanged,
    required this.onShadowChanged,
    required this.onSavePreferences,
    this.onPremiumPressed,
  }) : super(key: key);

  Widget _buildPremiumBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(BuildContext context, Widget child, {bool showBadge = true}) {
    return Stack(
      children: [
        !isPremium
            ? GestureDetector(
                onTap: onPremiumPressed,
                child: Opacity(
                  opacity: 0.5,
                  child: AbsorbPointer(child: child),
                ),
              )
            : child,
        if (!isPremium && showBadge)
          Positioned(
            top: 0,
            right: 0,
            child: _buildPremiumBadge(context),
          ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final modalTextColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: modalBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with close button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customize Appearance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: modalTextColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: modalTextColor),
                    onPressed: () {
                      onSavePreferences();
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Basic Features Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: modalTextColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Font Size Slider
                  Text(
                    'Font Size',
                    style: TextStyle(
                      fontSize: 16,
                      color: modalTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.purple,
                      inactiveTrackColor: Colors.purple.withOpacity(0.3),
                      thumbColor: Colors.purple,
                      overlayColor: Colors.purple.withOpacity(0.1),
                      valueIndicatorColor: Colors.purple,
                      trackHeight: 4,
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                        pressedElevation: 8,
                      ),
                    ),
                    child: Slider(
                      value: fontSize,
                      min: 12,
                      max: 24,
                      divisions: 12,
                      label: fontSize.round().toString(),
                      onChanged: onFontSizeChanged,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Opacity Slider
                  Text(
                    'Text Opacity',
                    style: TextStyle(
                      fontSize: 16,
                      color: modalTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.purple,
                      inactiveTrackColor: Colors.purple.withOpacity(0.3),
                      thumbColor: Colors.purple,
                      overlayColor: Colors.purple.withOpacity(0.1),
                      valueIndicatorColor: Colors.purple,
                      trackHeight: 4,
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                        pressedElevation: 8,
                      ),
                    ),
                    child: Slider(
                      value: opacity,
                      min: 0.3,
                      max: 0.9,
                      divisions: 6,
                      label: opacity.toStringAsFixed(1),
                      onChanged: onOpacityChanged,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Premium Features Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Premium Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: modalTextColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      _buildPremiumBadge(context),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Text Color Selection
                  _buildPremiumFeature(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Text Color',
                          style: TextStyle(
                            fontSize: 16,
                            color: modalTextColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showColorPicker(context, textColor, onTextColorChanged),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: textColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Background Color Selection
                  _buildPremiumFeature(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Background Color',
                          style: TextStyle(
                            fontSize: 16,
                            color: modalTextColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showColorPicker(context, backgroundColor, onBackgroundColorChanged),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Text Style Options
                  _buildPremiumFeature(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Text Style',
                          style: TextStyle(
                            fontSize: 16,
                            color: modalTextColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text('Bold'),
                                value: isBold,
                                onChanged: onBoldChanged,
                              ),
                              Divider(height: 1),
                              SwitchListTile(
                                title: Text('Italic'),
                                value: isItalic,
                                onChanged: onItalicChanged,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Text Shadow Toggle
                  _buildPremiumFeature(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Effects',
                          style: TextStyle(
                            fontSize: 16,
                            color: modalTextColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SwitchListTile(
                            title: Text('Text Shadow'),
                            value: hasShadow,
                            onChanged: onShadowChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 