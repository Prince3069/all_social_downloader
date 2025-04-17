// app.dart
import 'package:all_social_downloader/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
// import 'ui/screens/screens/home_screen.dart';
import 'ui/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status & Video Downloader',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
