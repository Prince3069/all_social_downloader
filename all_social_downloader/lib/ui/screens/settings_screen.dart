// ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/permission_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create the service as a constant without underscore
    final permissionService = PermissionService();

    return Scaffold(
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Storage section
              const ListTile(
                title: Text(
                  'Storage',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Download Location'),
                subtitle: Text(settings.downloadPath),
                onTap: () {
                  // Change download location
                },
              ),

              const Divider(),

              // Permissions section
              const ListTile(
                title: Text(
                  'Permissions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Storage Permission'),
                trailing: FutureBuilder<bool>(
                  // Pass context as the required positional argument
                  future: permissionService.requestRequiredPermissions(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return Icon(
                      snapshot.data == true ? Icons.check_circle : Icons.error,
                      color: snapshot.data == true ? Colors.green : Colors.red,
                    );
                  },
                ),
                onTap: () async {
                  // Pass context as the required positional argument
                  await permissionService.requestRequiredPermissions(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.window),
                title: const Text('Overlay Permission'),
                subtitle: const Text('Required for popup download button'),
                trailing: FutureBuilder<bool>(
                  future: permissionService.checkOverlayPermission(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return Icon(
                      snapshot.data == true ? Icons.check_circle : Icons.error,
                      color: snapshot.data == true ? Colors.green : Colors.red,
                    );
                  },
                ),
                onTap: () async {
                  await permissionService.requestOverlayPermission();
                },
              ),

              // Remaining code remains the same
              const Divider(),
              // App settings
              const ListTile(
                title: Text(
                  'App Settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Download Notifications'),
                subtitle:
                    const Text('Show notifications when download completes'),
                value: settings.showNotifications,
                onChanged: (value) {
                  settings.setShowNotifications(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.auto_fix_high),
                title: const Text('Auto-detect links'),
                subtitle: const Text('Detect video links from clipboard'),
                value: settings.autoDetectLinks,
                onChanged: (value) {
                  settings.setAutoDetectLinks(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.window),
                title: const Text('Show Floating Button'),
                subtitle: const Text('Display download button in other apps'),
                value: settings.showFloatingButton,
                onChanged: (value) {
                  settings.setShowFloatingButton(value);
                },
              ),

              const Divider(),

              // About section
              const ListTile(
                title: Text(
                  'About',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                onTap: () {
                  // Open privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate App'),
                onTap: () {
                  // Open app store page
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
