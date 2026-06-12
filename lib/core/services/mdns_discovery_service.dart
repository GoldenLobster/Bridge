import 'dart:async';
import 'dart:developer';

import 'package:bonsoir/bonsoir.dart';

import '../models/bridge_device.dart';

class MdnsDiscoveryService {
  final int serverPort;
  final String deviceId;
  final String deviceName;
  final String platform;

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySubscription;
  final StreamController<BridgeDevice> _controller =
      StreamController<BridgeDevice>.broadcast();

  Stream<BridgeDevice> get devices => _controller.stream;

  MdnsDiscoveryService({
    required this.serverPort,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
  });

  Future<void> start() async {
    try {
      _broadcast = BonsoirBroadcast(
        service: BonsoirService(
          name: deviceName,
          type: '_bridge._tcp',
          port: serverPort,
          attributes: {
            'deviceId': deviceId,
            'deviceName': deviceName,
            'platform': platform,
          },
        ),
      );
      await _broadcast!.initialize();
      await _broadcast!.start();
    } catch (e) {
      log('MdnsDiscoveryService: failed to start broadcast: $e');
    }

    try {
      _discovery = BonsoirDiscovery(type: '_bridge._tcp');
      await _discovery!.initialize();
      _discoverySubscription = _discovery!.eventStream?.listen(_onDiscoveryEvent);
      await _discovery!.start();
    } catch (e) {
      log('MdnsDiscoveryService: failed to start discovery: $e');
    }
  }

  void _onDiscoveryEvent(BonsoirDiscoveryEvent event) {
    if (event is BonsoirDiscoveryServiceFoundEvent) {
      final service = event.service;
      if (service.hostAddresses.isEmpty) {
        _discovery?.serviceResolver.resolveService(service);
      } else {
        _emitDeviceIfValid(service);
      }
    } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
      _emitDeviceIfValid(event.service);
    } else if (event is BonsoirDiscoveryServiceResolveFailedEvent) {
      log('MdnsDiscoveryService: resolve failed for a service');
    }
  }

  void _emitDeviceIfValid(BonsoirService service) {
    if (service.port == 0) return;

    final id = service.attributes['deviceId'] ?? '';
    if (id.isEmpty || id == deviceId) return;

    final ip = service.hostAddress ?? '';
    if (ip.isEmpty) return;

    _controller.add(BridgeDevice(
      id: id,
      name: service.attributes['deviceName'] ?? service.name,
      platform: service.attributes['platform'] ?? '',
      ip: ip,
      port: service.port,
    ));
  }

  Future<void> stop() async {
    await _discoverySubscription?.cancel();
    await _broadcast?.stop();
    await _discovery?.stop();
    await _controller.close();
  }
}
