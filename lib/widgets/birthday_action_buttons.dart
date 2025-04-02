import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class BirthdayActionButtons extends StatelessWidget {
  final Function(ImageSource) onPickImage;
  final VoidCallback onSave;
  final bool hasImage;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const BirthdayActionButtons({
    Key? key,
    required this.onPickImage,
    required this.onSave,
    required this.hasImage,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  void _showImageSourcePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                onPickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                onPickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                onPickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                onPickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return TextButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
      );
    }
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback to English strings if localization is not available
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () => onPickImage(ImageSource.camera),
          ),
          IconButton(
            icon: Icon(Icons.photo_library, color: Colors.white),
            onPressed: () => onPickImage(ImageSource.gallery),
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: onSave,
          ),
        ],
      );
    }
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context: context,
              icon: Icons.add_photo_alternate_outlined,
              label: AppLocalizations.of(context)!.addPhoto,
              onPressed: () => _showImageSourcePicker(context),
            ),
            _buildActionButton(
              context: context,
              icon: Icons.calendar_today_outlined,
              label: AppLocalizations.of(context)!.birthDate,
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onDateSelected(picked);
                }
              },
            ),
            if (hasImage && selectedDate != null)
              _buildActionButton(
                context: context,
                icon: Icons.save_alt_outlined,
                label: AppLocalizations.of(context)!.share,
                onPressed: onSave,
              ),
          ],
        );
      },
    );
  }
} 