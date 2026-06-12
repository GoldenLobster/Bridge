import 'dart:async';
import 'dart:developer';

import '../models/message.dart';
import '../networking/connection_manager.dart';
import '../networking/message_router.dart';

class PingService {
  final ConnectionManager _connectionManager;
  final MessageRouter _router;

  PingService(this._connectionManager, this._router) {
    _router.register('ping', _onPing);
  }

  void _onPing(Message message, String sourceDeviceId) {
    try {
      final pong = Message(
        type: 'pong',
        deviceId: '',
        payload: {},
      );
      _connectionManager.sendToDevice(sourceDeviceId, pong);
    } catch (e) {
      log('Failed to send pong to $sourceDeviceId: $e');
    }
  }

  Future<int> pingDevice(
    String deviceId, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<int>();
    final start = DateTime.now();

    final ping = Message(
      type: 'ping',
      deviceId: '',
      payload: {},
    );

    try {
      _connectionManager.sendToDevice(deviceId, ping);
    } catch (e) {
      throw StateError('Cannot send ping to $deviceId: $e');
    }

    StreamSubscription<({Message message, String sourceDeviceId})>? sub;
    sub = _router.events.listen((event) {
      if (event.message.type == 'pong' &&
          event.sourceDeviceId == deviceId &&
          !completer.isCompleted) {
        final rtt = DateTime.now().difference(start).inMilliseconds;
        completer.complete(rtt);
        sub?.cancel();
      }
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        sub?.cancel();
        completer.completeError(
          TimeoutException(
            'Ping to $deviceId timed out after ${timeout.inMilliseconds}ms',
          ),
        );
      }
    });

    return completer.future;
  }
}
