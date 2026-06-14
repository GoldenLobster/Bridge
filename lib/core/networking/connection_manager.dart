import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:pointycastle/digests/sha256.dart';

import '../models/message.dart';
import '../models/message_event.dart';
import '../security/certificate_manager.dart';
import 'connection_client.dart';
import 'connection_server.dart';
import 'connection_session.dart';
import 'message_router.dart';

typedef HeartbeatPing = Future<int> Function(
  String deviceId, {
  Duration timeout,
});

/// Manages the [ConnectionServer], tracks active [ConnectionSession]s by device ID, routes messages through a shared [MessageRouter], and handles automatic reconnection with exponential backoff.
class ConnectionManager {
  final int port;
  final MessageRouter router;
  final CertificateManager certManager;
  ConnectionServer? _server;
  StreamSubscription<ConnectionSession>? _serverSubscription;
  final Map<String, ConnectionSession> _sessions = {};
  final StreamController<MessageEvent> _eventController =
      StreamController<MessageEvent>.broadcast();

  final Map<String, _ReconnectState> _reconnectStates = {};
  final StreamController<({String deviceId, ReconnectStatus status})>
      _reconnectStatusController =
      StreamController<({String deviceId, ReconnectStatus status})>.broadcast();

  int _actualPort = 0;
  int get actualPort => _actualPort == 0 ? port : _actualPort;

  HeartbeatPing? _pingDevice;
  final Map<String, Timer> _heartbeatTimers = {};

  set pingDevice(HeartbeatPing fn) => _pingDevice = fn;

  ConnectionManager({
    required this.port,
    required this.router,
    required this.certManager,
  });

  Stream<MessageEvent> get events => _eventController.stream;

  Stream<({String deviceId, ReconnectStatus status})> get reconnectStatus =>
      _reconnectStatusController.stream;

  Future<void> start() async {
    if (_server != null) return;
    _server = ConnectionServer(
      port: port,
      securityContext: certManager.localContext,
    );
    try {
      await _server!.start();
    } on SocketException {
      await _server!.stop();
      _server = ConnectionServer(
        port: 0,
        securityContext: certManager.localContext,
      );
      await _server!.start();
    }
    _actualPort = _server!.actualPort;
    _serverSubscription = _server!.sessions.listen(_onNewSession);
  }

  Future<ConnectionSession> getOrCreateSession(
    String deviceId,
    String ip,
    int port,
  ) async {
    final existing = _sessions[deviceId];
    if (existing != null) {
      _resetReconnectState(deviceId);
      return existing;
    }
    final storedFingerprint = certManager.getStoredFingerprint(deviceId);
    final session = await ConnectionClient.connect(
      ip,
      port,
      context: certManager.localContext,
      onBadCertificate: (cert) {
        if (storedFingerprint == null) return true;
        final digest = SHA256Digest();
        final hash = digest.process(cert.der);
        final remote = base64.encode(hash);
        return remote == storedFingerprint;
      },
    );
    _sessions[deviceId] = session;
    _resetReconnectState(deviceId);
    _startHeartbeat(deviceId);
    session.messages.listen(
      (message) => _handleMessage(session, message, deviceId),
      onError: (error) => _eventController.addError(error),
      onDone: () => _removeSession(session),
    );
    return session;
  }

  void scheduleReconnect(String deviceId, String ip, int port) {
    final existing = _reconnectStates[deviceId];
    if (existing != null) {
      existing.ip = ip;
      existing.port = port;
      return;
    }
    final state = _ReconnectState()..ip = ip..port = port;
    _reconnectStates[deviceId] = state;
    _attemptReconnect(deviceId, state.ip, state.port, state);
  }

  void cancelReconnect(String deviceId) {
    final state = _reconnectStates.remove(deviceId);
    state?.timer?.cancel();
    _emitReconnectStatus(deviceId, ReconnectStatus.disconnected);
  }

  ReconnectStatus getReconnectStatus(String deviceId) {
    return _reconnectStates[deviceId]?.status ?? ReconnectStatus.disconnected;
  }

  Future<void> stop() async {
    for (final timer in _heartbeatTimers.values) {
      timer.cancel();
    }
    _heartbeatTimers.clear();
    for (final state in _reconnectStates.values) {
      state.timer?.cancel();
    }
    _reconnectStates.clear();
    await _serverSubscription?.cancel();
    for (final session in _sessions.values) {
      session.close();
    }
    _sessions.clear();
    await _server?.stop();
    await _eventController.close();
    await _reconnectStatusController.close();
  }

  static const _maxAttempts = 10;

  void _attemptReconnect(
    String deviceId,
    String ip,
    int port,
    _ReconnectState state,
  ) {
    if (state.attempts >= _maxAttempts) {
      _reconnectStates.remove(deviceId);
      _emitReconnectStatus(deviceId, ReconnectStatus.disconnected);
      return;
    }
    if (hasActiveSession(deviceId)) {
      _resetReconnectState(deviceId);
      _emitReconnectStatus(deviceId, ReconnectStatus.connected);
      return;
    }
    state.status = ReconnectStatus.reconnecting;
    _emitReconnectStatus(deviceId, ReconnectStatus.reconnecting);
    getOrCreateSession(deviceId, ip, port).then((_) {
      state.status = ReconnectStatus.connected;
      _emitReconnectStatus(deviceId, ReconnectStatus.connected);
    }).catchError((_) {
      state.attempts++;
      final delay = _backoffDelay(state.attempts);
      state.timer = Timer(
        delay,
        () => _attemptReconnect(deviceId, ip, port, state),
      );
    });
  }

  Duration _backoffDelay(int attempts) {
    final safe = attempts.clamp(1, 30);
    final ms = (2000 * (1 << (safe - 1))).clamp(2000, 60000);
    return Duration(milliseconds: ms);
  }

  void _resetReconnectState(String deviceId) {
    final state = _reconnectStates[deviceId];
    if (state != null) {
      state.timer?.cancel();
      state.attempts = 0;
      state.status = ReconnectStatus.connected;
    }
  }

  void _emitReconnectStatus(String deviceId, ReconnectStatus status) {
    _reconnectStatusController.add((deviceId: deviceId, status: status));
  }

  void _startHeartbeat(String deviceId) {
    _stopHeartbeat(deviceId);
    _heartbeatTimers[deviceId] = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performHeartbeat(deviceId),
    );
  }

  void _stopHeartbeat(String deviceId) {
    _heartbeatTimers.remove(deviceId)?.cancel();
  }

  Future<void> _performHeartbeat(String deviceId) async {
    final ping = _pingDevice;
    if (ping == null) return;
    try {
      await ping(deviceId, timeout: const Duration(seconds: 10));
    } catch (e) {
      log('ConnectionManager: heartbeat failed for $deviceId: $e');
      _stopHeartbeat(deviceId);
      final session = _sessions[deviceId];
      session?.close();
    }
  }

  void _onNewSession(ConnectionSession session) {
    session.messages.listen(
      (message) => _handleMessage(session, message, message.deviceId),
      onError: (error) => _eventController.addError(error),
      onDone: () => _removeSession(session),
    );
  }

  void _handleMessage(
    ConnectionSession session,
    Message message,
    String sourceDeviceId,
  ) {
    _eventController.add(MessageEvent(message, sourceDeviceId));

    if (message.type == 'handshake') {
      final remoteDeviceId =
          message.payload['deviceId'] as String? ?? message.deviceId;
      final existing = _sessions[remoteDeviceId];
      if (existing != null && existing != session) {
        existing.close();
      }
      _sessions[remoteDeviceId] = session;
      _resetReconnectState(remoteDeviceId);
      _startHeartbeat(remoteDeviceId);
    }

    router.route(message, sourceDeviceId);
  }

  bool hasActiveSession(String deviceId) {
    return _sessions.containsKey(deviceId);
  }

  void closeSession(String deviceId) {
    _stopHeartbeat(deviceId);
    final session = _sessions.remove(deviceId);
    session?.close();
    cancelReconnect(deviceId);
  }

  void sendToDevice(String deviceId, Message message) {
    final session = _sessions[deviceId];
    if (session == null) {
      throw StateError('No active session for device: $deviceId');
    }
    session.send(message);
  }

  void broadcast(Message message) {
    for (final session in _sessions.values) {
      try {
        session.send(message);
      } catch (_) {
      }
    }
  }

  void _removeSession(ConnectionSession session) {
    final deviceIds = _sessions
        .entries
        .where((e) => e.value == session)
        .map((e) => e.key)
        .toList();
    for (final id in deviceIds) {
      _sessions.remove(id);
      _stopHeartbeat(id);

      final state = _reconnectStates[id];
      if (state == null) {
        _emitReconnectStatus(id, ReconnectStatus.disconnected);
      } else {
        state.status = ReconnectStatus.disconnected;
        _emitReconnectStatus(id, ReconnectStatus.disconnected);
        if (state.attempts == 0) {
          state.attempts = 1;
          final delay = _backoffDelay(state.attempts);
          state.timer = Timer(
            delay,
            () => _attemptReconnect(id, state.ip, state.port, state),
          );
        }
      }
    }
  }
}

enum ReconnectStatus { disconnected, reconnecting, connected }

class _ReconnectState {
  int attempts = 0;
  Timer? timer;
  ReconnectStatus status = ReconnectStatus.disconnected;
  String ip = '';
  int port = 0;
}
