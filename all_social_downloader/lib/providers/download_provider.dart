// providers/download_provider.dart
import 'package:flutter/material.dart';
import '../models/download_item.dart';
import '../services/download_service.dart';
import '../services/notification_service.dart';

class DownloadProvider extends ChangeNotifier {
  final List<DownloadItem> _downloads = [];
  final DownloadService _downloadService = DownloadService();
  final NotificationService _notificationService = NotificationService();

  List<DownloadItem> get downloads => [..._downloads];

  Future<void> downloadFromUrl(String url) async {
    // Create a temporary item for the UI
    final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final DownloadItem tempItem = DownloadItem(
      id: uniqueId,
      url: url,
      fileName: 'download_$uniqueId.mp4',
      thumbnailUrl: '',
      sourceApp: '', // Will be determined later
      dateAdded: DateTime.now(),
      status: DownloadStatus.pending,
    );

    _downloads.add(tempItem);
    notifyListeners();

    // Show notification
    _notificationService.showDownloadProgressNotification(
      id: int.parse(uniqueId.substring(uniqueId.length - 9)),
      title: 'Downloading media',
      progress: 0.0,
    );

    try {
      final DownloadItem downloadItem =
          await _downloadService.downloadMedia(url);

      // Update the item in our list
      final int index = _downloads.indexWhere((item) => item.id == uniqueId);
      if (index >= 0) {
        _downloads[index] = downloadItem;
      }

      // Show completion notification
      _notificationService.showDownloadNotification(
        id: int.parse(uniqueId.substring(uniqueId.length - 9)),
        title: 'Download Complete',
        body: downloadItem.fileName,
        isComplete: true,
      );

      notifyListeners();
    } catch (e) {
      // Update status to failed
      final int index = _downloads.indexWhere((item) => item.id == uniqueId);
      if (index >= 0) {
        _downloads[index] =
            _downloads[index].copyWith(status: DownloadStatus.failed);
      }

      // Show error notification
      _notificationService.showDownloadNotification(
        id: int.parse(uniqueId.substring(uniqueId.length - 9)),
        title: 'Download Failed',
        body: 'Could not download media from $url',
        isComplete: false,
      );

      notifyListeners();
    }
  }

  void cancelDownload(String id) {
    final int index = _downloads.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _downloads[index] =
          _downloads[index].copyWith(status: DownloadStatus.canceled);

      // In a real app, you would cancel the actual download process here

      notifyListeners();
    }
  }

  void removeDownload(String id) {
    _downloads.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> retryDownload(String id) async {
    final int index = _downloads.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final String url = _downloads[index].url;
      await downloadFromUrl(url);
      removeDownload(id);
    }
  }
}
