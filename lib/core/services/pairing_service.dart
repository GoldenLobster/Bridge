import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';

import '../database/database.dart' hide Message;
import '../models/message.dart';
import '../networking/connection_manager.dart';
import '../networking/connection_session.dart';
import '../networking/message_router.dart';
import '../security/certificate_manager.dart';
import 'app_settings.dart';

class PairingService {
  final ConnectionManager _connectionManager;
  final MessageRouter _router;
  final AppSettings _settings;
  final BridgeDatabase _db;
  final CertificateManager _certManager;
  final StreamController<String> _pairedController =
      StreamController<String>.broadcast();

  Stream<String> get onPaired => _pairedController.stream;

  PairingService(
    this._connectionManager,
    this._router,
    this._settings,
    this._db,
    this._certManager,
  ) {
    _router.register('handshake', _onHandshake);
  }

  Future<void> _onHandshake(Message message, String sourceDeviceId) async {
    try {
      final remoteId = message.payload['deviceId'] as String? ?? '';
      final remoteName = message.payload['name'] as String? ?? '';
      final remotePlatform = message.payload['platform'] as String? ?? '';
      final remoteIp = message.payload['ip'] as String? ?? '';
      final remotePort = message.payload['port'] as int? ?? 0;
      final remoteTlsCert = message.payload['tlsCert'] as String? ?? '';

      if (remoteId.isEmpty || remoteId == _settings.deviceId) return;

      final alreadyPaired = await (_db.select(_db.devices)
            ..where((d) => d.id.equals(remoteId))
            ..where((d) => d.isPaired.equals(true)))
          .get();

      if (alreadyPaired.isNotEmpty) {
        await (_db.update(_db.devices)
              ..where((d) => d.id.equals(remoteId)))
            .write(DevicesCompanion(
              ip: Value(remoteIp),
              port: Value(remotePort),
              lastSeen: Value(DateTime.now()),
            ));

        final localIp = await _resolveLocalIp();
        final response = Message(
          type: 'handshake',
          deviceId: _settings.deviceId,
          payload: {
            'deviceId': _settings.deviceId,
            'name': _settings.deviceName,
            'platform': _settings.platform,
            'ip': localIp,
            'port': _connectionManager.actualPort,
          },
        );

        try {
          _connectionManager.sendToDevice(sourceDeviceId, response);
        } catch (e) {
          log('PairingService: failed to send ack: $e');
        }

        _pairedController.add(remoteName);
        return;
      }

      if (remoteTlsCert.isNotEmpty) {
        _certManager.addTrustedCertificate(remoteId, remoteTlsCert);
      }

      await _db.into(_db.devices).insertOnConflictUpdate(
        DevicesCompanion.insert(
          id: remoteId,
          name: remoteName,
          platform: remotePlatform,
          ip: remoteIp,
          port: remotePort,
          lastSeen: DateTime.now(),
          isPaired: true,
        ),
      );

      _pairedController.add(remoteName);

      final localIp = await _resolveLocalIp();

      final response = Message(
        type: 'handshake',
        deviceId: _settings.deviceId,
        payload: {
          'deviceId': _settings.deviceId,
          'name': _settings.deviceName,
          'platform': _settings.platform,
          'ip': localIp,
          'port': _connectionManager.actualPort,
          'tlsCert': _certManager.localCertPem,
        },
      );

      try {
        _connectionManager.sendToDevice(sourceDeviceId, response);
      } catch (e) {
        log('PairingService: failed to send handshake response: $e');
      }
    } catch (e) {
      log('PairingService: failed to process handshake: $e');
    }
  }

  Future<void> initiateHandshake(ConnectionSession session) async {
    final localIp = await _resolveLocalIp();
    final message = Message(
      type: 'handshake',
      deviceId: _settings.deviceId,
      payload: {
        'deviceId': _settings.deviceId,
        'name': _settings.deviceName,
        'platform': _settings.platform,
        'ip': localIp,
        'port': _connectionManager.actualPort,
        'tlsCert': _certManager.localCertPem,
      },
    );
    session.send(message);
  }

  static Future<String> _resolveLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '';
  }
}
