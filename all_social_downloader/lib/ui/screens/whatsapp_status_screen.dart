// ui/screens/whatsapp_status_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/status_item.dart';
import '../../services/storage_service.dart';
import '../widgets/ad_container.dart';

class WhatsAppStatusScreen extends StatefulWidget {
  const WhatsAppStatusScreen({Key? key}) : super(key: key);

  @override
  _WhatsAppStatusScreenState createState() => _WhatsAppStatusScreenState();
}

class _WhatsAppStatusScreenState extends State<WhatsAppStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();
  List<StatusItem> _statuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statuses = await _storageService.getWhatsAppStatuses();
      setState(() {
        _statuses = statuses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Status'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'IMAGES'),
            Tab(text: 'VIDEOS'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatuses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Images tab
                _buildStatusGrid(false),
                // Videos tab
                _buildStatusGrid(true),
              ],
            ),
    );
  }

  Widget _buildStatusGrid(bool isVideo) {
    final filteredStatuses =
        _statuses.where((status) => status.isVideo == isVideo).toList();

    if (filteredStatuses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No statuses found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check permissions or view some statuses first',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadStatuses,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const AdContainer(height: 60),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredStatuses.length,
            itemBuilder: (context, index) {
              final status = filteredStatuses[index];
              return _buildStatusItem(status);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(StatusItem status) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: status.isVideo
              ? _buildVideoThumbnail(status)
              : Image.file(
                  File(status.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 48),
                    );
                  },
                ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.7),
            radius: 16,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.download, size: 18, color: Colors.white),
              onPressed: () => _downloadStatus(status),
            ),
          ),
        ),
        if (status.isVideo)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  const Icon(Icons.play_arrow, size: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoThumbnail(StatusItem status) {
    // In real implementation, would use a video thumbnail generator
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.play_circle_fill,
          size: 48,
          color: Colors.white70,
        ),
      ),
    );
  }

  Future<void> _downloadStatus(StatusItem status) async {
    try {
      final path = await _storageService.saveStatus(status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to $path'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save status'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
