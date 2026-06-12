import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/models/pending_offer.dart';
import '../../core/providers/pending_offers_provider.dart';
import '../../core/services/file_transfer_service_provider.dart';

class PendingOfferDialog extends ConsumerStatefulWidget {
  const PendingOfferDialog({super.key});

  @override
  ConsumerState<PendingOfferDialog> createState() =>
      _PendingOfferDialogState();
}

class _PendingOfferDialogState extends ConsumerState<PendingOfferDialog> {
  bool _dialogShowing = false;
  final Set<String> _seenIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offers = ref.read(pendingOffersProvider);
      for (final o in offers) {
        if (_seenIds.add(o.transferId) && !_dialogShowing) {
          _showOffer(o.transferId);
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<PendingOffer>>(pendingOffersProvider, (prev, next) {
      if (!mounted) return;
      for (final o in next) {
        if (_seenIds.add(o.transferId) && !_dialogShowing) {
          _showOffer(o.transferId);
          break;
        }
      }
    });

    return const SizedBox.shrink();
  }

  Future<String> _resolveDeviceName(String deviceId) async {
    final db = await ref.read(databaseProvider.future);
    final devices = await (db.select(db.devices)
          ..where((d) => d.id.equals(deviceId)))
        .get();
    return devices.firstOrNull?.name ?? deviceId;
  }

  Future<void> _showOffer(String transferId) async {
    final offer = ref.read(pendingOffersProvider.notifier).getOffer(transferId);
    if (offer == null) return;

    final deviceName = await _resolveDeviceName(offer.deviceId);

    if (!mounted) return;

    _dialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Incoming File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.person, 'From', deviceName),
            const SizedBox(height: 8),
            _detailRow(Icons.insert_drive_file, 'File', offer.fileName),
            const SizedBox(height: 8),
            _detailRow(Icons.storage, 'Size', _formatFileSize(offer.fileSize)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _reject(transferId),
            child: const Text('Reject'),
          ),
          FilledButton(
            onPressed: () => _accept(transferId),
            child: const Text('Accept'),
          ),
        ],
      ),
    ).then((_) {
      _dialogShowing = false;
      if (!mounted) return;
      final remaining = ref.read(pendingOffersProvider);
      for (final o in remaining) {
        if (_seenIds.contains(o.transferId) && !_dialogShowing) {
          _showOffer(o.transferId);
          break;
        }
      }
    });
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _accept(String transferId) async {
    try {
      final service = await ref.read(fileTransferServiceProvider.future);
      await service.acceptOffer(transferId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept file: $e')),
        );
      }
    }
  }

  Future<void> _reject(String transferId) async {
    try {
      final service = await ref.read(fileTransferServiceProvider.future);
      service.rejectOffer(transferId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject file: $e')),
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
