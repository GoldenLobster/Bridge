import 'dart:io';

import 'package:path/path.dart' as p;

/// Serves a single file over HTTP for download by any browser on the local
/// network, enabling file sharing without Bridge installed on the receiving device.
class HttpShareServer {
  HttpServer? _server;
  String? _filePath;
  String? _fileName;
  int _fileSize = 0;
  String? _cachedUrl;

  bool get isRunning => _server != null;

  Future<String> get serverUrl async {
    if (_cachedUrl != null) return _cachedUrl!;
    final ip = await _resolveLocalIp();
    if (ip != null && _server != null) {
      return 'http://$ip:${_server!.port}/$_fileName';
    }
    if (_server != null) {
      return 'http://127.0.0.1:${_server!.port}/$_fileName';
    }
    throw StateError('Server is not running');
  }

  Future<void> start(String filePath) async {
    await stop();

    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }

    _filePath = filePath;
    _fileName = p.basename(filePath);
    _fileSize = await file.length();

    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server!.listen(_handleRequest);

    final ip = await _resolveLocalIp();
    if (ip != null) {
      _cachedUrl = 'http://$ip:${_server!.port}/$_fileName';
    } else {
      _cachedUrl = 'http://127.0.0.1:${_server!.port}/$_fileName';
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _filePath = null;
    _fileName = null;
    _fileSize = 0;
    _cachedUrl = null;
  }

  void _handleRequest(HttpRequest request) {
    final filePath = _filePath;
    final fileName = _fileName;
    final fileSize = _fileSize;

    _serveFile(request.response, filePath, fileName, fileSize);
  }

  Future<void> _serveFile(
    HttpResponse response,
    String? filePath,
    String? fileName,
    int fileSize,
  ) async {
    if (filePath == null || fileName == null) {
      response.statusCode = HttpStatus.serviceUnavailable;
      await response.close();
      return;
    }

    try {
      response.headers.set(
        'Content-Disposition',
        'attachment; filename="$fileName"',
      );
      response.headers.set('Content-Type', 'application/octet-stream');
      response.headers.set('Content-Length', fileSize.toString());

      final raf = await File(filePath).open(mode: FileMode.read);
      try {
        while (true) {
          final chunk = await raf.read(65536);
          if (chunk.isEmpty) break;
          response.add(chunk);
        }
        await response.close();
      } finally {
        await raf.close();
      }
    } catch (_) {
      try {
        await response.close();
      } catch (_) {}
    }
  }

  Future<String?> _resolveLocalIp() async {
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
    return null;
  }
}
