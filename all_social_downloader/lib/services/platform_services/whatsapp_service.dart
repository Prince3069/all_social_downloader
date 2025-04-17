// services/platform_services/whatsapp_service.dart
import 'dart:io';
import '../../models/status_item.dart';

class WhatsAppService {
  final String _statusPath = '/storage/emulated/0/WhatsApp/Media/.Statuses';
  final String _businessStatusPath =
      '/storage/emulated/0/WhatsApp Business/Media/.Statuses';
  final String _alternateStatusPath =
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
  final String _alternateBusinessStatusPath =
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses';

  // services/platform_services/whatsapp_service.dart (continued)
  Future<List<StatusItem>> getStatuses(
      {bool isBusinessWhatsApp = false}) async {
    // List of possible WhatsApp status paths
    final List<String> possiblePaths = isBusinessWhatsApp
        ? [
            _businessStatusPath,
            _alternateBusinessStatusPath,
            '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
            '/sdcard/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
          ]
        : [
            _statusPath,
            _alternateStatusPath,
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
            '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
            '/sdcard/WhatsApp/Media/.Statuses',
          ];

    // Try each path until we find one that exists
    String? validPath;
    for (final path in possiblePaths) {
      if (await Directory(path).exists()) {
        validPath = path;
        print('Found WhatsApp status path: $validPath');
        break;
      }
    }

    if (validPath == null) {
      print('No valid WhatsApp status path found');
      return [];
    }

    final List<FileSystemEntity> files = Directory(validPath).listSync();
    final List<StatusItem> statuses = [];

    for (FileSystemEntity file in files) {
      if (file is File) {
        final String path = file.path;
        final bool isVideo = path.endsWith('.mp4');

        if (isVideo || path.endsWith('.jpg') || path.endsWith('.png')) {
          try {
            final stat = file.statSync();
            statuses.add(StatusItem(
              id: path.split('/').last,
              path: path,
              isVideo: isVideo,
              createdAt: stat.modified,
            ));
            print('Added status: ${path.split('/').last}, isVideo: $isVideo');
          } catch (e) {
            print('Error adding status file: $path, error: $e');
          }
        }
      }
    }

    print('Found ${statuses.length} status items');
    return statuses;
  }

  Future<bool> isWhatsAppInstalled() async {
    // In a real app, would check if WhatsApp is installed
    return true;
  }
}
