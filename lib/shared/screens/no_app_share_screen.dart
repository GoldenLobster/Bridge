import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/services/http_share_server_provider.dart';

class NoAppShareScreen extends ConsumerStatefulWidget {
  const NoAppShareScreen({super.key});

  @override
  ConsumerState<NoAppShareScreen> createState() => _NoAppShareScreenState();
}

class _NoAppShareScreenState extends ConsumerState<NoAppShareScreen> {
  bool _isSharing = false;
  String? _fileName;
  int _fileSize = 0;
  String? _serverUrl;

  @override
  void dispose() {
    ref.read(httpShareServerProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Without App')),
      body: _isSharing ? _buildSharingBody() : _buildInitialBody(),
    );
  }

  Widget _buildInitialBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_tethering,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Share a file over your local network.\n'
            'No Bridge installation required on the receiving device.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.file_open),
            label: const Text('Pick File'),
            onPressed: _pickAndStart,
          ),
        ],
      ),
    );
  }

  Widget _buildSharingBody() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_download,
                size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              _fileName ?? '',
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _formatFileSize(_fileSize),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            QrImageView(data: _serverUrl!, size: 250),
            const SizedBox(height: 16),
            SelectableText(
              _serverUrl!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.stop),
              label: const Text('Stop Sharing'),
              onPressed: _stop,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndStart() async {
    try {
      final result = await FilePicker.pickFiles();
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;

      final file = result.files.first;
      final server = ref.read(httpShareServerProvider);
      await server.start(path);
      final url = await server.serverUrl;

      if (!mounted) return;
      setState(() {
        _isSharing = true;
        _fileName = file.name;
        _fileSize = file.size;
        _serverUrl = url;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start server: $e')),
        );
      }
    }
  }

  void _stop() {
    ref.read(httpShareServerProvider).stop();
    setState(() {
      _isSharing = false;
      _fileName = null;
      _fileSize = 0;
      _serverUrl = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
