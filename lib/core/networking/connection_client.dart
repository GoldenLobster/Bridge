import 'dart:io';

import 'connection_session.dart';

/// Opens a TLS connection to a remote host and port and wraps it in a [ConnectionSession].
class ConnectionClient {
  ConnectionClient._();

  static Future<ConnectionSession> connect(
    String host,
    int port, {
    Duration timeout = const Duration(seconds: 30),
    required SecurityContext context,
    required bool Function(X509Certificate) onBadCertificate,
  }) async {
    try {
      final socket = await SecureSocket.connect(
        host,
        port,
        timeout: timeout,
        context: context,
        onBadCertificate: onBadCertificate,
      );
      return ConnectionSession(socket);
    } catch (e) {
      throw StateError('Failed to connect to $host:$port: $e');
    }
  }
}
