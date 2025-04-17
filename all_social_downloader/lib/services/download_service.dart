// services/download_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/download_item.dart';
import '../utils/url_extractor.dart';
import 'storage_service.dart';
import 'platform_services/instagram_service.dart';
import 'platform_services/facebook_service.dart';
import 'platform_services/tiktok_service.dart';
import 'platform_services/twitter_service.dart';
import 'platform_services/youtube_service.dart';

class DownloadService {
  final StorageService _storageService = StorageService();
  final InstagramService _instagramService = InstagramService();
  final FacebookService _facebookService = FacebookService();
  final TikTokService _tiktokService = TikTokService();
  final TwitterService _twitterService = TwitterService();
  final YouTubeService _youtubeService = YouTubeService();

  Future<DownloadItem> downloadMedia(String url) async {
    // Extract information about the media
    final platform = UrlExtractor.detectPlatform(url);

    // Create download item
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    DownloadItem item = DownloadItem(
      id: uniqueId,
      url: url,
      fileName: 'download_$uniqueId.mp4',
      thumbnailUrl: '',
      sourceApp: platform,
      dateAdded: DateTime.now(),
    );

    // Get download URL based on platform
    String downloadUrl = '';
    switch (platform) {
      case 'instagram':
        downloadUrl = await _instagramService.getDownloadUrl(url);
        break;
      case 'facebook':
        downloadUrl = await _facebookService.getDownloadUrl(url);
        break;
      case 'tiktok':
        downloadUrl = await _tiktokService.getDownloadUrl(url);
        break;
      case 'twitter':
        downloadUrl = await _twitterService.getDownloadUrl(url);
        break;
      case 'youtube':
        downloadUrl = await _youtubeService.getDownloadUrl(url);
        break;
      default:
        downloadUrl = url;
    }

    // Start download
    try {
      final filePath = await _storageService
          .downloadFile(downloadUrl, item.fileName, (progress) {
        // Update progress callback
        item = item.copyWith(
          progress: progress,
          status: DownloadStatus.downloading,
        );
      });

      return item.copyWith(
        localPath: filePath,
        status: DownloadStatus.completed,
        progress: 1.0,
      );
    } catch (e) {
      return item.copyWith(status: DownloadStatus.failed);
    }
  }
}
