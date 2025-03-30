// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:cross_file/cross_file.dart';
// import 'package:screenshot/screenshot.dart';

// class ScreenshotService {
//   final ScreenshotController controller = ScreenshotController();

//   Future<String?> captureAndSave() async {
//     try {
//       // Capture the screenshot
//       final Uint8List? imageBytes = await controller.capture();
//       if (imageBytes == null) {
//         throw Exception('Failed to capture screenshot');
//       }

//       // Get application documents directory for permanent storage
//       final directory = await getApplicationDocumentsDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final filePath = '${directory.path}/anniversary_card_$timestamp.png';

//       // Create and write to file
//       File file = File(filePath);
//       await file.writeAsBytes(imageBytes);

//       return filePath;
//     } catch (e) {
//       print('Error capturing screenshot: $e');
//       return null;
//     }
//   }

//   void showSuccessDialog(BuildContext context, String filePath, Uint8List imageBytes) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
//           title: Text(
//             'Image Saved',
//             style: TextStyle(
//               color: isDarkMode ? Colors.white : Colors.black,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Your image has been saved successfully',
//                 style: TextStyle(
//                   color: isDarkMode ? Colors.white70 : Colors.black87,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Container(
//                 height: 200,
//                 width: 200,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: MemoryImage(imageBytes),
//                     fit: BoxFit.cover,
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Close',
//                 style: TextStyle(
//                   color: isDarkMode
//                       ? Colors.purple.shade200
//                       : Colors.purple.shade700,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Share.shareXFiles([XFile(filePath)],
//                     text: 'Check out my anniversary card!');
//               },
//               child: Text(
//                 'Share',
//                 style: TextStyle(
//                   color: isDarkMode
//                       ? Colors.purple.shade200
//                       : Colors.purple.shade700,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// } 