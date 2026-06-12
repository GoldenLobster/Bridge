import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/file_transfer_service_provider.dart';
import '../../core/services/file_transfer_service.dart';

class ActiveTransfersScreen extends ConsumerStatefulWidget {
  const ActiveTransfersScreen({super.key});

  @override
  ConsumerState<ActiveTransfersScreen> createState() =>
      _ActiveTransfersScreenState();
}

class _ActiveTransfersScreenState
    extends ConsumerState<ActiveTransfersScreen> {
  StreamSubscription<Set<String>>? _activeTransfersSub;
  bool _transfersListening = false;
  Set<String> _activeTransferIds = {};
  final Map<String, _SpeedTracker> _speedTrackers = {};

  @override
  void dispose() {
    _activeTransfersSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileTransferServiceAsync = ref.watch(fileTransferServiceProvider);
    final service = fileTransferServiceAsync.valueOrNull;

    if (service != null && !_transfersListening) {
      _transfersListening = true;
      _activeTransferIds = Set.from(service.activeTransferIds);
      _activeTransfersSub = service.onActiveTransfersChanged.listen((ids) {
        _speedTrackers
            .removeWhere((k, _) => !ids.contains(k));
        if (mounted) setState(() => _activeTransferIds = ids);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Active Transfers')),
      body: _activeTransferIds.isEmpty
          ? const Center(child: Text('No active transfers'))
          : ListView(
              children: _activeTransferIds.map((tid) {
                return _buildTransferItem(tid, service!);
              }).toList(),
            ),
    );
  }

  Widget _buildTransferItem(String transferId, FileTransferService service) {
    final fileName = service.getFileName(transferId) ?? transferId;
    final fileSize = service.getFileSize(transferId) ?? 0;

    return StreamBuilder<double>(
      stream: service.progress(transferId),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;

        final tracker = _speedTrackers.putIfAbsent(
          transferId,
          () => _SpeedTracker(fileSize),
        );
        tracker.update(progress);

        final isIncoming =
            service.getDirection(transferId) == 'incoming';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isIncoming ? Icons.file_download : Icons.file_upload,
                      size: 20,
                      color: isIncoming ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
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
                Row(
                  children: [
                    Text(
                      isIncoming ? 'Receiving' : 'Sending',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      tracker.formattedSpeed,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 28,
                      child: TextButton(
                        onPressed: () {
                          service.cancelTransfer(transferId);
                          if (mounted) setState(() {});
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _SpeedTracker {
  final int fileSize;
  double _lastProgress = 0;
  DateTime _lastTime = DateTime.now();
  double _speedBytesPerSec = 0;

  _SpeedTracker(this.fileSize);

  void update(double progress) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastTime).inMilliseconds / 1000.0;
    if (elapsed >= 0.5) {
      final delta = progress - _lastProgress;
      if (delta > 0) {
        _speedBytesPerSec = (delta * fileSize) / elapsed;
      }
      _lastProgress = progress;
      _lastTime = now;
    }
  }

  String get formattedSpeed {
    if (_speedBytesPerSec >= 1024 * 1024) {
      return '${(_speedBytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    } else if (_speedBytesPerSec >= 1024) {
      return '${(_speedBytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${_speedBytesPerSec.toStringAsFixed(0)} B/s';
    }
  }
}
