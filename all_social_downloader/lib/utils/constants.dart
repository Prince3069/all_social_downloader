// utils/constants.dart
class Constants {
  static const String appName = 'Status & Video Downloader';
  static const String defaultDownloadPath =
      '/storage/emulated/0/Download/VideoDownloader';

  // WhatsApp paths
  static const String whatsAppStatusPath =
      '/storage/emulated/0/WhatsApp/Media/.Statuses';
  static const String whatsAppBusinessStatusPath =
      '/storage/emulated/0/WhatsApp Business/Media/.Statuses';

  // Alternative WhatsApp paths (Android 11+)
  static const String altWhatsAppStatusPath =
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
  static const String altWhatsAppBusinessStatusPath =
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses';

  // Supported social media apps
  static const Map<String, String> socialMediaPackages = {
    'instagram': 'com.instagram.android',
    'facebook': 'com.facebook.katana',
    'tiktok': 'com.zhiliaoapp.musically',
    'twitter': 'com.twitter.android',
    'youtube': 'com.google.android.youtube',
  };
}
