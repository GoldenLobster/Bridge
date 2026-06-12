import 'dart:async';
import 'dart:io';

import 'connection_session.dart';

/// Binds a [SecureServerSocket] on a configurable port and emits a [ConnectionSession] for every accepted incoming TLS connection.
class ConnectionServer {
  final int port;
  final SecurityContext securityContext;
  SecureServerSocket? _serverSocket;
  final StreamController<ConnectionSession> _sessionController;
  StreamSubscription<SecureSocket>? _subscription;

  ConnectionServer({required this.port, required this.securityContext})
      : _sessionController = StreamController<ConnectionSession>.broadcast();

  Stream<ConnectionSession> get sessions => _sessionController.stream;

  Future<void> start() async {
    try {
      _serverSocket = await SecureServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
        securityContext,
      );
    } catch (e) {
      throw StateError('Failed to bind secure server on port $port: $e');
    }
    _subscription = _serverSocket!.listen(
      (socket) {
        final session = ConnectionSession(socket);
        _sessionController.add(session);
      },
      onError: (error) {
        _sessionController.addError(error);
      },
      onDone: () {
        _serverSocket = null;
        _sessionController.close();
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    if (_serverSocket != null) {
      await _serverSocket!.close();
      _serverSocket = null;
    }
    if (!_sessionController.isClosed) {
      await _sessionController.close();
    }
  }
}
