import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/database/database.dart' as db;
import '../../core/database/providers.dart';
import '../../core/networking/connection_manager.dart';
import '../../core/providers/connection_providers.dart';
import '../../core/services/app_settings_provider.dart';
import '../../core/services/file_transfer_service_provider.dart';
import '../../core/services/file_transfer_service.dart';
import '../../core/utils/network_utils.dart';
import '../../mobile/screens/qr_scanner_screen.dart';
import 'active_transfers_screen.dart';
import 'no_app_share_screen.dart';
import 'transfer_history_screen.dart';

final pairedDevicesProvider = FutureProvider<List<db.Device>>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return (database.select(database.devices)
        ..where((d) => d.isPaired.equals(true)))
      .get();
});

class PairedDevicesScreen extends ConsumerStatefulWidget {
  final List<String>? filePaths;

  const PairedDevicesScreen({super.key, this.filePaths});

  @override
  ConsumerState<PairedDevicesScreen> createState() =>
      _PairedDevicesScreenState();
}

class _PairedDevicesScreenState extends ConsumerState<PairedDevicesScreen> {
  StreamSubscription<Set<String>>? _activeTransfersSub;
  Set<String> _activeTransferIds = {};

  @override
  void dispose() {
    _activeTransfersSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(pairedDevicesProvider);
    final connectionManager = ref.watch(connectionManagerProvider);
    final fileTransferServiceAsync = ref.watch(fileTransferServiceProvider);
    final isDesktop =
        Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    final service = fileTransferServiceAsync.valueOrNull;

    if (service != null && _activeTransfersSub == null) {
      _activeTransferIds = Set.from(service.activeTransferIds);
      _activeTransfersSub = service.onActiveTransfersChanged.listen((ids) {
        if (mounted) setState(() => _activeTransferIds = ids);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ActiveTransfersScreen()),
            ),
            tooltip: 'Active Transfers',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TransferHistoryScreen()),
            ),
            tooltip: 'Transfer History',
          ),
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NoAppShareScreen()),
            ),
            tooltip: 'Share Without App',
          ),
        ],
      ),
      body: _buildBody(
        devicesAsync,
        connectionManager,
        service,
        isDesktop,
      ),
      floatingActionButton: devicesAsync.valueOrNull?.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () => _openPairing(isDesktop),
              icon: Icon(isDesktop ? Icons.qr_code : Icons.qr_code_scanner),
              label:
                  Text(isDesktop ? 'Show Pairing QR' : 'Pair New Device'),
            )
          : null,
    );
  }

  Widget _buildFilesReadyBanner(List<String> paths) {
    final names = paths.map((p) => p.split('/').last).join(', ');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.file_present, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${paths.length} file(s) ready to send:\n$names',
              style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No paired devices'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openPairing(isDesktop),
            icon:
                Icon(isDesktop ? Icons.qr_code : Icons.qr_code_scanner),
            label: Text(
                isDesktop ? 'Show Pairing QR' : 'Pair New Device'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferTile(
    String transferId,
    FileTransferService service,
  ) {
    final fileName = service.getFileName(transferId) ?? transferId;

    return StreamBuilder<double>(
      stream: service.progress(transferId),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.swap_vert, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceTile(
    db.Device device,
    ConnectionManager connectionManager,
    FileTransferService? service,
  ) {
    final isOnline = connectionManager.hasActiveSession(device.id);
    final reconnectStatus =
        connectionManager.getReconnectStatus(device.id);
    final isReconnecting =
        reconnectStatus == ReconnectStatus.reconnecting;

    IconData icon;
    Color iconColor;
    String subtitleText;
    if (isOnline) {
      icon = Icons.circle;
      iconColor = Colors.green;
      subtitleText = device.platform;
    } else if (isReconnecting) {
      icon = Icons.sync;
      iconColor = Colors.orange;
      subtitleText = 'Reconnecting...';
    } else {
      icon = Icons.circle_outlined;
      iconColor = Colors.grey;
      subtitleText = 'Tap to connect';
    }

    return ListTile(
      key: ValueKey(device.id),
      leading: Icon(icon, color: iconColor),
      title: Text(device.name,
          overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(subtitleText,
          overflow: TextOverflow.ellipsis, maxLines: 1),
      onTap: isOnline || isReconnecting
          ? null
          : () => _reconnect(device, connectionManager),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOnline)
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () => _sendFile(device.id, service),
              tooltip: 'Send File',
            ),
          if (!isOnline && !isReconnecting)
            IconButton(
              icon: const Icon(Icons.wifi_find),
              onPressed: () => _reconnect(device, connectionManager),
              tooltip: 'Connect',
            ),
          IconButton(
            icon: const Icon(Icons.link_off),
            onPressed: () => _unpair(device),
            tooltip: 'Unpair',
          ),
        ],
      ),
    );
  }

  Future<void> _reconnect(
    db.Device device,
    ConnectionManager connectionManager,
  ) async {
    connectionManager.scheduleReconnect(device.id, device.ip, device.port);
  }

  Widget _buildBody(
    AsyncValue<List<db.Device>> devicesAsync,
    ConnectionManager connectionManager,
    FileTransferService? service,
    bool isDesktop,
  ) {
    final devices = devicesAsync.valueOrNull ?? [];
    final hasContent =
        devices.isNotEmpty || _activeTransferIds.isNotEmpty;

    final contentChildren = <Widget>[
      if (widget.filePaths != null && widget.filePaths!.isNotEmpty) ...[
        _buildFilesReadyBanner(widget.filePaths!),
      ],
      if (_activeTransferIds.isNotEmpty && service != null) ...[
        _buildSectionHeader('Transfers'),
        ..._activeTransferIds.map(
            (tid) => _buildTransferTile(tid, service)),
      ],
      if (devices.isNotEmpty) ...[
        _buildSectionHeader('Paired Devices'),
        ...devices.map(
            (d) => _buildDeviceTile(d, connectionManager, service)),
      ],
    ];

    if (!hasContent) {
      if (devicesAsync.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (devicesAsync.hasError) {
        return Center(child: Text('${devicesAsync.error}'));
      }
      return _buildEmptyState(isDesktop);
    }

    if (isDesktop) {
      return ListView(children: contentChildren);
    }
    return SingleChildScrollView(child: Column(children: contentChildren));
  }

  void _openPairing(bool isDesktop) {
    if (isDesktop) {
      _showQrDialog(context, ref);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const QrScannerScreen(isPairingFromList: true),
        ),
      );
    }
  }

  Future<void> _showQrDialog(
      BuildContext context, WidgetRef ref) async {
    final settings = await ref.read(appSettingsProvider.future);
    final connectionManager = ref.read(connectionManagerProvider);
    final interfaces = await NetworkInterface.list();
    final ip = firstNonLoopbackIpv4(interfaces);

    if (ip == null || !context.mounted) return;

    final portStr = await settings.get('serverPort');
    if (!context.mounted) return;
    final port = portStr != null
        ? int.parse(portStr)
        : connectionManager.actualPort;
    final name = settings.deviceName.isNotEmpty
        ? settings.deviceName
        : 'Desktop';
    final payload = {
      'deviceId': settings.deviceId,
      'ip': ip,
      'port': port,
    };
    final json = jsonEncode(payload);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(name, overflow: TextOverflow.ellipsis, maxLines: 1),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: QrImageView(data: json, size: 250),
            ),
            const SizedBox(height: 16),
            Text('$ip:$port',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFile(
      String deviceId, FileTransferService? service) async {
    if (service == null) return;

    try {
      final List<String> paths;
      if (widget.filePaths != null && widget.filePaths!.isNotEmpty) {
        paths = widget.filePaths!;
      } else {
        final result = await FilePicker.pickFiles();
        if (result == null || result.files.isEmpty) return;
        final path = result.files.first.path;
        if (path == null) return;
        paths = [path];
      }

      for (final path in paths) {
        await service.sendFile(deviceId, path);
      }

      if (widget.filePaths != null && widget.filePaths!.isNotEmpty) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PairedDevicesScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send file: $e')),
        );
      }
    }
  }

  Future<void> _unpair(db.Device device) async {
    try {
      final database = await ref.read(databaseProvider.future);
      final connectionManager = ref.read(connectionManagerProvider);

      connectionManager.closeSession(device.id);
      await (database.delete(database.devices)
            ..where((d) => d.id.equals(device.id)))
          .go();
      ref.invalidate(pairedDevicesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unpair: $e')),
        );
      }
    }
  }

}


