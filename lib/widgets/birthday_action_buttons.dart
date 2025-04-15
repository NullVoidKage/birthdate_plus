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
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              print('Date selected: ${picked.toIso8601String()}');
              onDateSelected(picked);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          onPressed: () => onPickImage(ImageSource.camera),
        ),
        IconButton(
          icon: const Icon(Icons.photo_library, color: Colors.white),
          onPressed: () => onPickImage(ImageSource.gallery),
        ),
        if (hasImage && selectedDate != null)
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onSave,
          ),
      ],
    );
  }
} 