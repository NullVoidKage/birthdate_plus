import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BottomButtons extends StatelessWidget {
  final VoidCallback onSetDate;
  final Function(ImageSource) onCamera;
  final Function(ImageSource) onGallery;
  final VoidCallback onSave;

  const BottomButtons({
    Key? key,
    required this.onSetDate,
    required this.onCamera,
    required this.onGallery,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            icon: Icons.calendar_today_rounded,
            label: 'Set Date',
            onPressed: onSetDate,
            context: context,
          ),
          _buildButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            onPressed: () => onCamera(ImageSource.camera),
            context: context,
          ),
          _buildButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onPressed: () => onGallery(ImageSource.gallery),
            context: context,
          ),
          _buildButton(
            icon: Icons.save,
            label: 'Save',
            onPressed: onSave,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.pink.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 