import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/providers/connection_providers.dart';
import '../../core/services/app_settings.dart';
import '../../core/services/app_settings_provider.dart';
import '../../core/services/pairing_service_provider.dart';
import '../../shared/screens/paired_devices_screen.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  String? _pairedDeviceName;
  StreamSubscription<String>? _onPairedSub;
  bool _listening = false;

  @override
  void dispose() {
    _onPairedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final pairingServiceAsync = ref.watch(pairingServiceProvider);
    final connectionManager = ref.watch(connectionManagerProvider);

    if (!_listening) {
      final pairingService = pairingServiceAsync.valueOrNull;
      if (pairingService != null) {
        _listening = true;
        _onPairedSub = pairingService.onPaired.listen((name) {
          if (mounted) {
            setState(() => _pairedDeviceName = name);
          }
        });
      }
    }

    if (_pairedDeviceName != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bridge')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                'Paired with $_pairedDeviceName',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PairedDevicesScreen(),
                    ),
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bridge')),
      body: settingsAsync.when(
        data: (settings) => FutureBuilder<List<NetworkInterface>>(
          future: NetworkInterface.list(),
          builder: (context, snapshot) {
            final ip = _firstNonLoopbackIpv4(snapshot.data);

            if (ip == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final name = _deviceName(settings);
            final payload = {
              'deviceId': settings.deviceId,
              'ip': ip,
              'port': connectionManager.port,
            };
            final json = jsonEncode(payload);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: json,
                    size: 250,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$ip:${connectionManager.port}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  String _deviceName(AppSettings settings) {
    final name = settings.deviceName;
    return name.isNotEmpty ? name : 'Desktop';
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
}
