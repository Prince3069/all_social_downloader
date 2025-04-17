// ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/social_media_card.dart';
import '../../models/social_media_platform.dart';
import '../../providers/download_provider.dart';
import 'downloads_screen.dart';
import 'whatsapp_status_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const WhatsAppStatusScreen(),
    const DownloadsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status & Video Downloader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show about dialog
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            label: 'WhatsApp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _urlController = TextEditingController();

  final List<SocialMediaPlatform> platforms = [
    const SocialMediaPlatform(
      id: 'instagram',
      name: 'Instagram',
      icon: 'assets/icons/instagram.png',
      packageName: 'com.instagram.android',
    ),
    const SocialMediaPlatform(
      id: 'facebook',
      name: 'Facebook',
      icon: 'assets/icons/facebook.png',
      packageName: 'com.facebook.katana',
    ),
    const SocialMediaPlatform(
      id: 'tiktok',
      name: 'TikTok',
      icon: 'assets/icons/tiktok.png',
      packageName: 'com.zhiliaoapp.musically',
    ),
    const SocialMediaPlatform(
      id: 'twitter',
      name: 'Twitter',
      icon: 'assets/icons/twitter.png',
      packageName: 'com.twitter.android',
    ),
    const SocialMediaPlatform(
      id: 'youtube',
      name: 'YouTube',
      icon: 'assets/icons/youtube.png',
      packageName: 'com.google.android.youtube',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Paste video URL',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.paste),
                  onPressed: () async {
                    // Paste from clipboard
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Download button
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (_urlController.text.isNotEmpty) {
                  Provider.of<DownloadProvider>(context, listen: false)
                      .downloadFromUrl(_urlController.text);
                  _urlController.clear();
                }
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'Supported Platforms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Platform grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: platforms.length,
              itemBuilder: (context, index) {
                return SocialMediaCard(
                  platform: platforms[index],
                  onTap: () {
                    // Open app
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
