// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showDownloadNotification({
    required int id,
    required String title,
    required String body,
    required bool isComplete,
  }) async {
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showProgress: false,
    );

    NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> showDownloadProgressNotification({
    required int id,
    required String title,
    required double progress,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_progress_channel',
      'Download Progress',
      channelShowBadge: false,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: (progress * 100).toInt(),
    );

    NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      'Downloading: ${(progress * 100).toInt()}%',
      platformDetails,
    );
  }
}
