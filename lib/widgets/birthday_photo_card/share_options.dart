import 'package:flutter/material.dart';

class ShareOptions extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onShareInstagram;
  final VoidCallback onShareWhatsApp;

  const ShareOptions({
    Key? key,
    required this.onSave,
    required this.onShareInstagram,
    required this.onShareWhatsApp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Color(0xFF2C2C2C) 
            : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share Your Photo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                icon: Icons.photo_library,
                label: 'Save',
                onTap: onSave,
              ),
              _buildShareOption(
                icon: Icons.camera_alt,
                label: 'Instagram',
                onTap: onShareInstagram,
              ),
              _buildShareOption(
                icon: Icons.message,
                label: 'WhatsApp',
                onTap: onShareWhatsApp,
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.purple, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 