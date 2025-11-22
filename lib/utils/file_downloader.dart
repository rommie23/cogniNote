import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class FileDownloader {
  static Future<String?> downloadPdfToDevice(
      List<int> pdfBytes, String fileName) async {
    try {
      // Request storage permission first
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      if (Platform.isAndroid) {
        return await _savePdfAndroid(pdfBytes, fileName);
      } else if (Platform.isIOS) {
        return await _savePdfIOS(pdfBytes, fileName);
      }
      return null;
    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }

  static Future<String?> _savePdfAndroid(
      List<int> bytes, String fileName) async {
    try {
      // Try to save to Downloads folder
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Use Download folder
        final downloadsPath = '${directory.path}/Download';
        final downloadsDir = Directory(downloadsPath);

        // Create Download folder if it doesn't exist
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        // Save the file
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);

        // Try to open the file to show success
        await OpenFile.open(file.path);
        return file.path;
      }

      // Fallback to app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      await OpenFile.open(file.path);
      return file.path;
    } catch (e) {
      print('Android save error: $e');
      rethrow;
    }
  }

  static Future<String?> _savePdfIOS(List<int> bytes, String fileName) async {
    try {
      // For iOS, save to documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      // Open the file
      await OpenFile.open(file.path);
      return file.path;
    } catch (e) {
      print('iOS save error: $e');
      rethrow;
    }
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check current permission status
      var status = await Permission.storage.status;

      // If not granted, request it
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      return status.isGranted;
    }

    // For iOS, return true as we don't need storage permission for app directory
    return true;
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
    return true;
  }
}
