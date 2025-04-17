// ui/screens/downloads_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/download_provider.dart';
import '../../models/download_item.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Downloads'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ALL'),
              Tab(text: 'VIDEOS'),
              Tab(text: 'IMAGES'),
            ],
          ),
        ),
        body: Consumer<DownloadProvider>(
          builder: (context, provider, child) {
            if (provider.downloads.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_done_rounded,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No downloads yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Downloads will appear here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                // All downloads tab
                _buildDownloadsList(provider.downloads),
                // Videos tab
                _buildDownloadsList(provider.downloads
                    .where((item) =>
                        item.fileName.endsWith('.mp4') ||
                        item.fileName.endsWith('.mov'))
                    .toList()),
                // Images tab
                _buildDownloadsList(provider.downloads
                    .where((item) =>
                        item.fileName.endsWith('.jpg') ||
                        item.fileName.endsWith('.jpeg') ||
                        item.fileName.endsWith('.png'))
                    .toList()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDownloadsList(List<DownloadItem> downloads) {
    if (downloads.isEmpty) {
      return const Center(
        child: Text('No items in this category'),
      );
    }

    return ListView.builder(
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final item = downloads[index];
        return ListTile(
          leading: _buildItemLeading(item),
          title: Text(item.fileName),
          subtitle: Text('${item.sourceApp} • ${_formatDate(item.dateAdded)}'),
          trailing: _buildItemTrailing(context, item),
          onTap: () {
            // Open file
          },
        );
      },
    );
  }

  Widget _buildItemLeading(DownloadItem item) {
    if (item.thumbnailUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          item.thumbnailUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultThumbnail(item);
          },
        ),
      );
    }
    return _buildDefaultThumbnail(item);
  }

  Widget _buildDefaultThumbnail(DownloadItem item) {
    IconData iconData = Icons.insert_drive_file;

    if (item.fileName.endsWith('.mp4') || item.fileName.endsWith('.mov')) {
      iconData = Icons.video_file;
    } else if (item.fileName.endsWith('.jpg') ||
        item.fileName.endsWith('.jpeg') ||
        item.fileName.endsWith('.png')) {
      iconData = Icons.image;
    }

    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: Center(
        child: Icon(iconData, size: 32),
      ),
    );
  }

  Widget _buildItemTrailing(BuildContext context, DownloadItem item) {
    switch (item.status) {
      case DownloadStatus.pending:
        return IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // Start download
          },
        );
      case DownloadStatus.downloading:
        return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: item.progress,
                strokeWidth: 2,
              ),
              Center(
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    // Cancel download
                  },
                ),
              ),
            ],
          ),
        );
      case DownloadStatus.completed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Share file
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options
              },
            ),
          ],
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.refresh, color: Colors.red),
          onPressed: () {
            // Retry download
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
