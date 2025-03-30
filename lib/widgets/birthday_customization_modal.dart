import 'package:flutter/material.dart';

class BirthdayCustomizationModal extends StatelessWidget {
  final double fontSize;
  final double opacity;
  final Function(double) onFontSizeChanged;
  final Function(double) onOpacityChanged;
  final VoidCallback onSavePreferences;

  const BirthdayCustomizationModal({
    Key? key,
    required this.fontSize,
    required this.opacity,
    required this.onFontSizeChanged,
    required this.onOpacityChanged,
    required this.onSavePreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
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
          // Font Size Slider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Font Size',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
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
              ],
            ),
          ),
          SizedBox(height: 24),
          // Opacity Slider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text Opacity',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
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
          SizedBox(height: 24),
        ],
      ),
    );
  }
} 