import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/database/database.dart' as db;
import '../../core/database/providers.dart';
import '../../core/models/pending_offer.dart';
import '../../core/networking/connection_manager.dart';
import '../../core/providers/connection_providers.dart';
import '../../core/providers/pending_offers_provider.dart';
import '../../core/services/app_settings_provider.dart';
import '../../core/services/file_transfer_service_provider.dart';
import '../../core/services/file_transfer_service.dart';
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
  const PairedDevicesScreen({super.key});

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
    final pendingOffers = ref.watch(pendingOffersProvider);
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

    final deviceMap = devicesAsync.valueOrNull
            ?.fold<Map<String, db.Device>>({}, (map, d) {
          map[d.id] = d;
          return map;
        }) ??
        {};

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
      body: devicesAsync.when(
        data: (devices) {
          final hasContent = devices.isNotEmpty ||
              pendingOffers.isNotEmpty ||
              _activeTransferIds.isNotEmpty;

          if (!hasContent) {
            return _buildEmptyState(isDesktop);
          }

          return ListView(
            children: [
              if (pendingOffers.isNotEmpty) ...[
                _buildSectionHeader('Incoming Files'),
                ...pendingOffers.map(
                    (o) => _buildPendingOfferCard(o, deviceMap)),
              ],
              if (_activeTransferIds.isNotEmpty && service != null) ...[
                _buildSectionHeader('Transfers'),
                ..._activeTransferIds.map(
                    (tid) => _buildTransferTile(tid, service, deviceMap)),
              ],
              if (devices.isNotEmpty) ...[
                _buildSectionHeader('Paired Devices'),
                ...devices.map(
                    (d) => _buildDeviceTile(d, connectionManager, service)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
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

  Widget _buildPendingOfferCard(
    PendingOffer offer,
    Map<String, db.Device> deviceMap,
  ) {
    final deviceName = deviceMap[offer.deviceId]?.name ?? offer.deviceId;
    final sizeStr = _formatFileSize(offer.fileSize);

    return Card(
      key: ValueKey('pending_${offer.transferId}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_download, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    offer.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(sizeStr,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text('From: $deviceName',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _rejectOffer(offer.transferId),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _acceptOffer(offer.transferId),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferTile(
    String transferId,
    FileTransferService service,
    Map<String, db.Device> deviceMap,
  ) {
    final deviceId = service.getDeviceIdForTransfer(transferId) ?? '';
    final deviceName = deviceMap[deviceId]?.name ?? deviceId;
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
                const SizedBox(height: 4),
                Text(deviceName,
                    style: Theme.of(context).textTheme.bodySmall),
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
      subtitleText = device.platform;
    }

    return ListTile(
      key: ValueKey(device.id),
      leading: Icon(icon, color: iconColor),
      title: Text(device.name,
          overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(subtitleText,
          overflow: TextOverflow.ellipsis, maxLines: 1),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOnline)
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () => _sendFile(device.id, service),
              tooltip: 'Send File',
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

  void _openPairing(bool isDesktop) {
    if (isDesktop) {
      _showQrDialog(context, ref);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
    }
  }

  Future<void> _showQrDialog(
      BuildContext context, WidgetRef ref) async {
    final settings = await ref.read(appSettingsProvider.future);
    final connectionManager = ref.read(connectionManagerProvider);
    final interfaces = await NetworkInterface.list();
    final ip = _firstNonLoopbackIpv4(interfaces);

    if (ip == null || !context.mounted) return;

    final name = settings.deviceName.isNotEmpty
        ? settings.deviceName
        : 'Desktop';
    final payload = {
      'deviceId': settings.deviceId,
      'ip': ip,
      'port': connectionManager.port,
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
            Text('$ip:${connectionManager.port}',
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

  Future<void> _acceptOffer(String transferId) async {
    try {
      final service = await ref.read(fileTransferServiceProvider.future);
      await service.acceptOffer(transferId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: $e')),
        );
      }
    }
  }

  Future<void> _rejectOffer(String transferId) async {
    try {
      final service = await ref.read(fileTransferServiceProvider.future);
      service.rejectOffer(transferId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    }
  }

  Future<void> _sendFile(
      String deviceId, FileTransferService? service) async {
    if (service == null) return;

    try {
      final result = await FilePicker.pickFiles();
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;

      await service.sendFile(deviceId, path);
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

String? _firstNonLoopbackIpv4(List<NetworkInterface>? interfaces) {
  if (interfaces == null) return null;
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
        return addr.address;
      }
    }
  }
  return null;
}
