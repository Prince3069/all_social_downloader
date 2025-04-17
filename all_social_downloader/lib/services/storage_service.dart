// services/storage_service.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/status_item.dart';

class StorageService {
  Future<String> get _downloadsDirectory async {
    if (Platform.isAndroid) {
      Directory? directory = await getExternalStorageDirectory();
      return '${directory!.path}/Downloads';
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/Downloads';
    }
  }

  Future<String> downloadFile(
      String url, String fileName, Function(double) onProgress) async {
    final directory = await _downloadsDirectory;
    final filePath = '$directory/$fileName';
    final file = File(filePath);

    // Create directory if it doesn't exist
    if (!await Directory(directory).exists()) {
      await Directory(directory).create(recursive: true);
    }

    // Download logic
    // (Simplified for brevity, would use dio or http package with progress)
    try {
      // Simulated download for code sample
      for (int i = 0; i < 10; i++) {
        await Future.delayed(Duration(milliseconds: 100));
        onProgress(i / 10);
      }

      // In actual implementation, use:
      // final response = await Dio().download(url, filePath,
      //   onReceiveProgress: (received, total) {
      //     onProgress(received / total);
      //   }
      // );

      onProgress(1.0);
      return filePath;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  Future<List<StatusItem>> getWhatsAppStatuses() async {
    // Path where WhatsApp stores status
    String statusPath = '/storage/emulated/0/WhatsApp/Media/.Statuses';

    if (!await Directory(statusPath).exists()) {
      statusPath =
          '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
      if (!await Directory(statusPath).exists()) {
        return [];
      }
    }

    final List<FileSystemEntity> files = Directory(statusPath).listSync();
    final List<StatusItem> statuses = [];

    for (FileSystemEntity file in files) {
      if (file is File) {
        final String path = file.path;
        final bool isVideo = path.endsWith('.mp4');

        if (isVideo || path.endsWith('.jpg') || path.endsWith('.png')) {
          statuses.add(StatusItem(
            id: path.split('/').last,
            path: path,
            isVideo: isVideo,
            createdAt: file.statSync().modified,
          ));
        }
      }
    }

    return statuses;
  }

  Future<String> saveStatus(StatusItem status) async {
    final sourceFile = File(status.path);
    final directory = await _downloadsDirectory;
    final fileName = status.path.split('/').last;
    final destinationPath = '$directory/$fileName';

    try {
      // Create directory if it doesn't exist
      if (!await Directory(directory).exists()) {
        await Directory(directory).create(recursive: true);
      }

      // Copy the file
      await sourceFile.copy(destinationPath);

      // Make the file visible to gallery apps by scanning it
      await _scanFile(destinationPath);

      return destinationPath;
    } catch (e) {
      print('Error saving status: $e');
      throw Exception('Failed to save file: $e');
    }
  }

  Future<void> _scanFile(String filePath) async {
    try {
      // For Android only
      if (Platform.isAndroid) {
        // Using method channel to call MediaScanner
        const platform =
            MethodChannel('com.example.all_social_downloader/media_scanner');
        await platform.invokeMethod('scanFile', {'path': filePath});
      }
    } catch (e) {
      print('Media scanning failed: $e');
    }
  }
}
