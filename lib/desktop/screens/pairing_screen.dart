import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/database/providers.dart';
import '../../core/providers/connection_providers.dart';
import '../../core/services/app_settings.dart';
import '../../core/services/app_settings_provider.dart';
import '../../core/services/pairing_service_provider.dart';
import '../../core/utils/network_utils.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final db = await ref.read(databaseProvider.future);
      final paired = await (db.select(db.devices)
            ..where((d) => d.isPaired.equals(true)))
          .get();
      if (paired.isNotEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PairedDevicesScreen(),
          ),
        );
      }
    });
  }

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
        data: (settings) => FutureBuilder<List<dynamic>>(
          future: Future.wait([
            NetworkInterface.list(),
            settings.get('serverPort'),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final interfaces = snapshot.data![0] as List<NetworkInterface>;
            final portStr = snapshot.data![1] as String?;
            final ip = firstNonLoopbackIpv4(interfaces);

            if (ip == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final port = portStr != null
                ? int.parse(portStr)
                : connectionManager.actualPort;
            final name = _deviceName(settings);
            final payload = {
              'deviceId': settings.deviceId,
              'ip': ip,
              'port': port,
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
                    '$ip:$port',
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

}
