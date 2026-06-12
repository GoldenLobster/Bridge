import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/device_list_provider.dart';
import '../../core/services/ping_service_provider.dart';

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(deviceListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bridge')),
      body: devicesAsync.when(
        data: (devices) => ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              leading: const Icon(Icons.circle, color: Colors.green),
              title: Text(device.name),
              subtitle: Text('${device.platform}  ${device.ip}'),
              trailing: ElevatedButton(
                onPressed: () => _pingDevice(context, ref, device.id),
                child: const Text('Ping'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _pingDevice(
    BuildContext context,
    WidgetRef ref,
    String deviceId,
  ) async {
    final pingService = ref.read(pingServiceProvider);
    try {
      final rtt = await pingService.pingDevice(deviceId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('RTT: ${rtt}ms')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }
}
