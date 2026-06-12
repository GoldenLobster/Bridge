import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/providers.dart';
import '../models/bridge_device.dart';
import '../networking/connection_manager.dart';
import '../services/app_settings_provider.dart';
import '../services/mdns_discovery_service.dart';
import '../services/pairing_service_provider.dart';
import 'connection_providers.dart';

class DeviceListNotifier extends AsyncNotifier<List<BridgeDevice>> {
  MdnsDiscoveryService? _discoveryService;
  StreamSubscription<BridgeDevice>? _subscription;
  StreamSubscription<({String deviceId, ReconnectStatus status})>?
      _reconnectSubscription;
  late ConnectionManager _connectionManager;
  late BridgeDatabase _db;

  @override
  Future<List<BridgeDevice>> build() async {
    final settings = await ref.read(appSettingsProvider.future);
    _connectionManager = ref.read(connectionManagerProvider);
    _db = await ref.read(databaseProvider.future);

    _reconnectSubscription =
        _connectionManager.reconnectStatus.listen((event) async {
      if (event.status != ReconnectStatus.connected) return;
      final pairingService = await ref.read(pairingServiceProvider.future);
      try {
        final session = await _connectionManager.getOrCreateSession(
          event.deviceId,
          '',
          0,
        );
        pairingService.initiateHandshake(session);
      } catch (e) {
        log('DeviceListNotifier: handshake after reconnect failed: $e');
      }
    });

    _discoveryService = MdnsDiscoveryService(
      serverPort: _connectionManager.port,
      deviceId: settings.deviceId,
      deviceName: settings.deviceName,
      platform: settings.platform,
    );
    await _discoveryService!.start();

    _subscription = _discoveryService!.devices.listen(_onDeviceDiscovered);

    ref.onDispose(() {
      _subscription?.cancel();
      _reconnectSubscription?.cancel();
      _discoveryService?.stop();
    });

    return [];
  }

  void _onDeviceDiscovered(BridgeDevice device) {
    final current = <BridgeDevice>[...state.value ?? []];
    final index = current.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      current[index] = device;
    } else {
      current.add(device);
    }
    state = AsyncData(current);

    _initiateConnection(device);
  }

  Future<void> _initiateConnection(BridgeDevice device) async {
    try {
      final paired = await (_db.select(_db.devices)
            ..where((d) => d.id.equals(device.id))
            ..where((d) => d.isPaired.equals(true)))
          .get();

      if (paired.isEmpty) return;
      if (_connectionManager.hasActiveSession(device.id)) return;

      _connectionManager.scheduleReconnect(device.id, device.ip, device.port);
    } catch (e) {
      log('DeviceListNotifier: failed to initiate connection to ${device.name}: $e');
    }
  }
}

final deviceListProvider =
    AsyncNotifierProvider<DeviceListNotifier, List<BridgeDevice>>(
  DeviceListNotifier.new,
);
