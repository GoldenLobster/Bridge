import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../core/database/database.dart' hide Message;
import '../../core/database/providers.dart';

class TransferHistoryItem {
  final Transfer transfer;
  final String? deviceName;

  const TransferHistoryItem({required this.transfer, this.deviceName});
}

final transferHistoryProvider = FutureProvider<List<TransferHistoryItem>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final transfers = await (db.select(db.transfers)
        ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
      .get();
  final devices = await (db.select(db.devices)).get();
  final deviceMap = {for (final d in devices) d.id: d.name};
  return transfers
      .map((t) => TransferHistoryItem(transfer: t, deviceName: deviceMap[t.deviceId]))
      .toList();
});

class TransferHistoryScreen extends ConsumerWidget {
  const TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transferHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer History')),
      body: historyAsync.when(
        data: (transfers) {
          if (transfers.isEmpty) {
            return const Center(child: Text('No transfers yet'));
          }

          return ListView.builder(
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final item = transfers[index];
              final t = item.transfer;
              final isIncoming = t.direction == 'incoming';
              final deviceLabel = item.deviceName != null
                  ? (isIncoming ? 'From: ${item.deviceName}' : 'To: ${item.deviceName}')
                  : null;

              IconData statusIcon;
              Color statusColor;
              switch (t.status) {
                case 'completed':
                  statusIcon = Icons.check_circle;
                  statusColor = Colors.green;
                  break;
                case 'failed':
                  statusIcon = Icons.error;
                  statusColor = Colors.red;
                  break;
                case 'cancelled':
                case 'rejected':
                  statusIcon = Icons.cancel;
                  statusColor = Colors.grey;
                  break;
                default:
                  statusIcon = Icons.schedule;
                  statusColor = Colors.orange;
              }

              return ListTile(
                leading: Icon(
                  isIncoming ? Icons.file_download : Icons.file_upload,
                  color: isIncoming ? Colors.blue : Colors.orange,
                ),
                title: Text(
                  t.fileName,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  [
                    ?deviceLabel,
                    '${_formatFileSize(t.fileSize)}  \u2022  ${_formatTimestamp(t.timestamp)}',
                  ].join('\n'),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(statusIcon, color: statusColor),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
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

  String _formatTimestamp(DateTime ts) {
    return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}'
        ' ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
  }
}
