import 'package:flutter/material.dart';

class UploadPictureDialog extends StatelessWidget {
  const UploadPictureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF8B0000);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      contentPadding: const EdgeInsets.all(24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 60,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload a file',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop('file_chosen');
            },
            icon: const Icon(Icons.image_outlined, color: Colors.white),
            label: const Text('Choose File', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
