// // services/permission_service.dart
// import 'package:permission_handler/permission_handler.dart';

// class PermissionService {
//   Future<bool> requestRequiredPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.storage,
//       Permission.accessMediaLocation,
//       Permission.manageExternalStorage,
//       Permission.systemAlertWindow, // For overlay
//     ].request();

//     return statuses.values.every((status) => status.isGranted);
//   }

//   Future<bool> checkOverlayPermission() async {
//     return await Permission.systemAlertWindow.isGranted;
//   }

//   Future<bool> requestOverlayPermission() async {
//     if (await Permission.systemAlertWindow.isGranted) {
//       return true;
//     } else {
//       final status = await Permission.systemAlertWindow.request();
//       return status.isGranted;
//     }
//   }
// }

// services/permission_service.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestRequiredPermissions(BuildContext context) async {
    // Different permissions for Android 13+ vs older versions
    List<Permission> permissions = [];

    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        // Android 13+ (API 33+) uses more granular permissions
        permissions = [
          Permission.photos,
          Permission.videos,
          Permission.notification,
          Permission.systemAlertWindow, // For overlay
        ];
      } else {
        // Older Android versions
        permissions = [
          Permission.storage,
          Permission.accessMediaLocation,
          Permission.manageExternalStorage,
          Permission.notification,
          Permission.systemAlertWindow, // For overlay
        ];
      }
    } else if (Platform.isIOS) {
      permissions = [
        Permission.photos,
        Permission.mediaLibrary,
      ];
    }

    // Request permissions
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Check if any permission was permanently denied
    List<Permission> deniedPermissions = [];
    for (var entry in statuses.entries) {
      if (entry.value.isPermanentlyDenied) {
        deniedPermissions.add(entry.key);
      }
    }

    // Show dialog if any permission is permanently denied
    if (deniedPermissions.isNotEmpty && context.mounted) {
      _showPermissionDeniedDialog(context, deniedPermissions);
      return false;
    }

    return statuses.values.every((status) => status.isGranted);
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  void _showPermissionDeniedDialog(
      BuildContext context, List<Permission> deniedPermissions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(
          'To use this app, please grant the required permissions in app settings: '
          '${deniedPermissions.map((p) => p.toString().split('.').last).join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<bool> checkOverlayPermission() async {
    return await Permission.systemAlertWindow.isGranted;
  }

  Future<bool> requestOverlayPermission() async {
    if (await Permission.systemAlertWindow.isGranted) {
      return true;
    } else {
      final status = await Permission.systemAlertWindow.request();
      return status.isGranted;
    }
  }
}
