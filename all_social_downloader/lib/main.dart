// // main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'app.dart';
// import 'providers/download_provider.dart';
// import 'providers/settings_provider.dart';
// import 'services/notification_service.dart';
// import 'services/permission_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize services
//   await NotificationService().init();
//   await PermissionService().requestRequiredPermissions();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => DownloadProvider()),
//         ChangeNotifierProvider(create: (_) => SettingsProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/download_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';
// Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService().init();

  // We can't request permissions here since we need context
  // We'll handle permissions in the app's first screen instead

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        Provider<PermissionService>(create: (_) => PermissionService()),
      ],
      child: const MyApp(),
    ),
  );
}
