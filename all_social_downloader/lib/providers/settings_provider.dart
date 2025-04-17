// providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _showNotifications = true;
  bool _autoDetectLinks = true;
  bool _showFloatingButton = true;
  String _downloadPath = Constants.defaultDownloadPath;

  // Getters
  bool get showNotifications => _showNotifications;
  bool get autoDetectLinks => _autoDetectLinks;
  bool get showFloatingButton => _showFloatingButton;
  String get downloadPath => _downloadPath;

  // Constructor loads settings
  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _showNotifications = prefs.getBool('show_notifications') ?? true;
    _autoDetectLinks = prefs.getBool('auto_detect_links') ?? true;
    _showFloatingButton = prefs.getBool('show_floating_button') ?? true;
    _downloadPath =
        prefs.getString('download_path') ?? Constants.defaultDownloadPath;

    notifyListeners();
  }

  Future<void> setShowNotifications(bool value) async {
    _showNotifications = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_notifications', value);
    notifyListeners();
  }

  Future<void> setAutoDetectLinks(bool value) async {
    _autoDetectLinks = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_detect_links', value);
    notifyListeners();
  }

  Future<void> setShowFloatingButton(bool value) async {
    _showFloatingButton = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_floating_button', value);
    notifyListeners();
  }

  Future<void> setDownloadPath(String path) async {
    _downloadPath = path;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('download_path', path);
    notifyListeners();
  }
}
