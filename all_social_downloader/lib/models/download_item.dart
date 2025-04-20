// models/download_item.dart
class DownloadItem {
  final String id;
  final String url;
  final String fileName;
  final String thumbnailUrl;
  final String sourceApp;
  final DateTime dateAdded;
  final String localPath;
  final DownloadStatus status;
  final double progress;

  DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.thumbnailUrl,
    required this.sourceApp,
    required this.dateAdded,
    this.localPath = '',
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
  });

  DownloadItem copyWith({
    String? localPath,
    DownloadStatus? status,
    double? progress,
  }) {
    return DownloadItem(
      id: id,
      url: url,
      fileName: fileName,
      thumbnailUrl: thumbnailUrl,
      sourceApp: sourceApp,
      dateAdded: dateAdded,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}

enum DownloadStatus { pending, downloading, completed, failed, canceled }
