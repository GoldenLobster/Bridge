import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart' hide Message;
import '../models/message.dart';
import '../models/pending_offer.dart';
import '../networking/connection_manager.dart';
import '../networking/message_router.dart';
import '../providers/pending_offers_provider.dart';
import 'app_settings.dart';

/// Sends files to paired devices and receives incoming file transfers over TCP
/// sessions with chunked transfer, progress reporting, and cancellation support.
class FileTransferService {
  final ConnectionManager _connectionManager;
  final MessageRouter _router;
  final AppSettings _settings;
  final BridgeDatabase _db;
  final PendingOffersNotifier _pendingOffersNotifier;

  final Map<String, StreamController<double>> _progressControllers = {};
  final Map<String, Completer<bool>> _pendingOfferCompleters = {};
  final Map<String, String> _transferDeviceIds = {};
  final Map<String, String> _transferFileNames = {};
  final Map<String, int> _transferFileSizes = {};
  final Map<String, String> _transferDirections = {};
  final Map<String, bool> _cancelled = {};
  final StreamController<Set<String>> _activeTransfersController =
      StreamController<Set<String>>.broadcast();

  final Map<String, IOSink> _incomingSinks = {};
  final Map<String, String> _incomingFilePaths = {};
  final Map<String, int> _incomingBytesReceived = {};
  StreamSubscription<({String deviceId, ReconnectStatus status})>?
      _reconnectSubscription;

  FileTransferService(
    this._connectionManager,
    this._router,
    this._settings,
    this._db,
    this._pendingOffersNotifier,
  ) {
    _router.register('file_accept', _onFileAccept);
    _router.register('file_reject', _onFileReject);
    _router.register('file_cancel', _onFileCancel);
    _router.register('file_offer', _onFileOffer);
    _router.register('file_chunk', _onFileChunk);
    _router.register('file_complete', _onFileComplete);

    _reconnectSubscription =
        _connectionManager.reconnectStatus.listen((event) {
      if (event.status == ReconnectStatus.disconnected) {
        _onDeviceDisconnected(event.deviceId);
      }
    });
  }

  Set<String> get activeTransferIds =>
      Set.unmodifiable(_transferDeviceIds.keys);

  Stream<Set<String>> get onActiveTransfersChanged =>
      _activeTransfersController.stream;

  String? getDeviceIdForTransfer(String transferId) =>
      _transferDeviceIds[transferId];

  String? getFileName(String transferId) =>
      _transferFileNames[transferId];

  int? getFileSize(String transferId) =>
      _transferFileSizes[transferId];

  String? getDirection(String transferId) =>
      _transferDirections[transferId];

  void _notifyActiveTransfers() {
    _activeTransfersController.add(Set.from(_transferDeviceIds.keys));
  }

  Stream<double> progress(String transferId) =>
      _progressControllers[transferId]?.stream ?? const Stream.empty();

  Future<String> sendFile(String deviceId, String filePath) async {
    final file = File(filePath);
    final fileName = p.basename(filePath);
    final fileSize = await file.length();
    final transferId = const Uuid().v4();

    _transferDeviceIds[transferId] = deviceId;
    _transferFileNames[transferId] = fileName;
    _transferFileSizes[transferId] = fileSize;
    _transferDirections[transferId] = 'outgoing';
    _notifyActiveTransfers();

    await _db.into(_db.transfers).insert(
          TransfersCompanion.insert(
            id: transferId,
            deviceId: deviceId,
            fileName: fileName,
            fileSize: fileSize,
            direction: 'outgoing',
            status: 'pending',
            timestamp: DateTime.now(),
          ),
        );

    final progressController = StreamController<double>.broadcast();
    _progressControllers[transferId] = progressController;
    progressController.add(0.0);

    final completer = Completer<bool>();
    _pendingOfferCompleters[transferId] = completer;

    _connectionManager.sendToDevice(
      deviceId,
      Message(
        type: 'file_offer',
        deviceId: _settings.deviceId,
        payload: {
          'transferId': transferId,
          'fileName': fileName,
          'fileSize': fileSize,
        },
      ),
    );

    bool accepted;
    try {
      accepted = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
            'File transfer offer timed out for $fileName'),
      );
    } on TimeoutException {
      _pendingOfferCompleters.remove(transferId);
      _updateTransferStatus(transferId, 'failed');
      _progressControllers.remove(transferId)?.close();
      rethrow;
    }

    if (_cancelled[transferId] == true) {
      _cleanupCancelled(transferId);
      return transferId;
    }

    if (!accepted) {
      _updateTransferStatus(transferId, 'rejected');
      _progressControllers.remove(transferId)?.close();
      _pendingOfferCompleters.remove(transferId);
      _transferDeviceIds.remove(transferId);
      _transferFileNames.remove(transferId);
      _transferFileSizes.remove(transferId);
      _transferDirections.remove(transferId);
      _notifyActiveTransfers();
      throw StateError('File transfer rejected by remote device');
    }

    _updateTransferStatus(transferId, 'transferring');

    try {
      final totalChunks = (fileSize + 65535) ~/ 65536;
      final randomAccessFile = await file.open();
      bool cancelledByUser = false;
      try {
        int chunkIndex = 0;
        while (true) {
          if (_cancelled[transferId] == true) {
            cancelledByUser = true;
            break;
          }

          final chunk = await randomAccessFile.read(65536);
          if (chunk.isEmpty) break;

          final encoded = base64.encode(chunk);

          _connectionManager.sendToDevice(
            deviceId,
            Message(
              type: 'file_chunk',
              deviceId: _settings.deviceId,
              payload: {
                'transferId': transferId,
                'chunkIndex': chunkIndex,
                'totalChunks': totalChunks,
                'data': encoded,
              },
            ),
          );

          chunkIndex++;
          progressController.add(chunkIndex / totalChunks);
        }
      } finally {
        await randomAccessFile.close();
      }

      if (cancelledByUser) {
        _cleanupCancelled(transferId);
        return transferId;
      }

      _connectionManager.sendToDevice(
        deviceId,
        Message(
          type: 'file_complete',
          deviceId: _settings.deviceId,
          payload: {'transferId': transferId},
        ),
      );

      _updateTransferStatus(transferId, 'completed');
      progressController.add(1.0);
      return transferId;
    } catch (e) {
      _updateTransferStatus(transferId, 'failed');
      progressController.addError(e);
      log('FileTransferService: sendFile failed for $transferId: $e');
      rethrow;
    } finally {
      try {
        await progressController.close();
      } catch (_) {}
      _progressControllers.remove(transferId);
      _pendingOfferCompleters.remove(transferId);
      _transferDeviceIds.remove(transferId);
      _transferFileNames.remove(transferId);
      _transferFileSizes.remove(transferId);
      _transferDirections.remove(transferId);
      _notifyActiveTransfers();
    }
  }

  void cancelTransfer(String transferId) {
    _cancelled[transferId] = true;

    final deviceId = _transferDeviceIds[transferId];
    if (deviceId != null) {
      try {
        _connectionManager.sendToDevice(
          deviceId,
          Message(
            type: 'file_cancel',
            deviceId: _settings.deviceId,
            payload: {'transferId': transferId},
          ),
        );
      } catch (_) {
      }
    }

    _cleanupCancelled(transferId);
  }

  Future<void> acceptOffer(String transferId) async {
    final pendingOffer = _pendingOffersNotifier.getOffer(transferId);
    if (pendingOffer == null) return;

    _pendingOffersNotifier.removeOffer(transferId);

    final dir = await _resolveDownloadDir();
    final filePath = _resolveFilePath(dir, pendingOffer.fileName);

    try {
      final file = File(filePath);
      final sink = file.openWrite();

      _connectionManager.sendToDevice(
        pendingOffer.deviceId,
        Message(
          type: 'file_accept',
          deviceId: _settings.deviceId,
          payload: {'transferId': transferId},
        ),
      );

      await _db.into(_db.transfers).insert(
            TransfersCompanion.insert(
              id: transferId,
              deviceId: pendingOffer.deviceId,
              fileName: pendingOffer.fileName,
              fileSize: pendingOffer.fileSize,
              direction: 'incoming',
              status: 'transferring',
              timestamp: DateTime.now(),
            ),
          );

      _incomingSinks[transferId] = sink;
      _incomingFilePaths[transferId] = filePath;
      _incomingBytesReceived[transferId] = 0;

      final progressController = StreamController<double>.broadcast();
      _progressControllers[transferId] = progressController;
      progressController.add(0.0);
      _transferDeviceIds[transferId] = pendingOffer.deviceId;
      _transferFileNames[transferId] = pendingOffer.fileName;
      _transferFileSizes[transferId] = pendingOffer.fileSize;
      _transferDirections[transferId] = 'incoming';
      _notifyActiveTransfers();
    } catch (e) {
      log('FileTransferService: failed to accept offer $transferId: $e');
      try {
        _connectionManager.sendToDevice(
          pendingOffer.deviceId,
          Message(
            type: 'file_cancel',
            deviceId: _settings.deviceId,
            payload: {'transferId': transferId},
          ),
        );
      } catch (_) {}
    }
  }

  void rejectOffer(String transferId) {
    final pendingOffer = _pendingOffersNotifier.getOffer(transferId);
    if (pendingOffer == null) return;

    _pendingOffersNotifier.removeOffer(transferId);

    try {
      _connectionManager.sendToDevice(
        pendingOffer.deviceId,
        Message(
          type: 'file_reject',
          deviceId: _settings.deviceId,
          payload: {'transferId': transferId},
        ),
      );
    } catch (_) {
    }
  }

  void _cleanupCancelled(String transferId) {
    _cancelled.remove(transferId);
    _updateTransferStatus(transferId, 'cancelled');
    _progressControllers.remove(transferId)?.close();
    _pendingOfferCompleters.remove(transferId);
    _transferDeviceIds.remove(transferId);
    _transferFileNames.remove(transferId);
    _transferFileSizes.remove(transferId);
    _transferDirections.remove(transferId);
    _notifyActiveTransfers();
  }

  void _onFileAccept(Message message, String sourceDeviceId) {
    final transferId = message.payload['transferId'] as String?;
    if (transferId == null) return;
    final completer = _pendingOfferCompleters.remove(transferId);
    completer?.complete(true);
  }

  void _onFileReject(Message message, String sourceDeviceId) {
    final transferId = message.payload['transferId'] as String?;
    if (transferId == null) return;
    final completer = _pendingOfferCompleters.remove(transferId);
    completer?.complete(false);
  }

  void _onFileOffer(Message message, String sourceDeviceId) {
    final transferId = message.payload['transferId'] as String?;
    final fileName = message.payload['fileName'] as String?;
    final fileSize = message.payload['fileSize'] as int?;
    if (transferId == null || fileName == null || fileSize == null) return;

    _pendingOffersNotifier.addOffer(
      PendingOffer(
        transferId: transferId,
        deviceId: sourceDeviceId,
        fileName: fileName,
        fileSize: fileSize,
      ),
    );
  }

  void _onFileChunk(Message message, String sourceDeviceId) {
    final transferId = message.payload['transferId'] as String?;
    if (transferId == null) return;

    final sink = _incomingSinks[transferId];
    if (sink == null) return;

    final encoded = message.payload['data'] as String?;
    if (encoded == null) return;

    final bytes = base64.decode(encoded);
    sink.add(bytes);

    _incomingBytesReceived[transferId] =
        (_incomingBytesReceived[transferId] ?? 0) + bytes.length;

    final progressController = _progressControllers[transferId];
    if (progressController != null) {
      final totalChunks = message.payload['totalChunks'] as int? ?? 1;
      final chunkIndex = message.payload['chunkIndex'] as int? ?? 0;
      progressController.add((chunkIndex + 1) / totalChunks);
    }
  }

  void _onFileComplete(Message message, String sourceDeviceId) {
    final transferId = message.payload['transferId'] as String?;
    if (transferId == null) return;

    unawaited(_finalizeIncoming(transferId));
  }

  void _onFileCancel(Message message, String sourceDeviceId) {
    final transferId = message.payload['transferId'] as String?;
    if (transferId == null) return;

    if (_incomingSinks.containsKey(transferId)) {
      _cleanupIncomingTransfer(transferId, 'failed');
    } else {
      _pendingOffersNotifier.removeOffer(transferId);
      _cancelled[transferId] = true;
      _updateTransferStatus(transferId, 'cancelled');
      _progressControllers.remove(transferId)?.close();
      _pendingOfferCompleters.remove(transferId);
      _transferDeviceIds.remove(transferId);
      _transferFileNames.remove(transferId);
      _transferFileSizes.remove(transferId);
      _transferDirections.remove(transferId);
      _notifyActiveTransfers();
    }
  }

  void dispose() {
    _reconnectSubscription?.cancel();
    for (final sink in _incomingSinks.values) {
      sink.close();
    }
    _incomingSinks.clear();
    _incomingFilePaths.clear();
    _incomingBytesReceived.clear();
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    for (final completer in _pendingOfferCompleters.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Service disposed'));
      }
    }
    _pendingOfferCompleters.clear();
    _transferDeviceIds.clear();
    _transferFileNames.clear();
    _transferFileSizes.clear();
    _transferDirections.clear();
    _cancelled.clear();
    _activeTransfersController.close();
  }

  void _updateTransferStatus(String transferId, String status) {
    try {
      (_db.update(_db.transfers)..where((t) => t.id.equals(transferId))).write(
        TransfersCompanion(status: Value(status)),
      );
    } catch (e) {
      log('FileTransferService: failed to update transfer $transferId status to $status: $e');
    }
  }

  void _onDeviceDisconnected(String deviceId) {
    final activeIds = _transferDeviceIds.entries
        .where((e) => e.value == deviceId)
        .map((e) => e.key)
        .toList();
    for (final tid in activeIds) {
      if (_incomingSinks.containsKey(tid)) {
        _cleanupIncomingTransfer(tid, 'failed');
      }
    }

    final pendingIds = _pendingOffersNotifier
        .getOffersByDevice(deviceId)
        .map((o) => o.transferId)
        .toList();
    for (final tid in pendingIds) {
      _pendingOffersNotifier.removeOffer(tid);
    }
  }

  Future<Directory> _resolveDownloadDir() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'];
      if (home != null) {
        final downloads = Directory(p.join(home, 'Downloads'));
        if (await downloads.exists()) return downloads;
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    return Directory(dir.path);
  }

  String _resolveFilePath(Directory dir, String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    final ext = dot > 0 ? fileName.substring(dot) : '';
    var name = fileName;
    for (int i = 1; i <= 999; i++) {
      if (!File(p.join(dir.path, name)).existsSync()) break;
      name = '$base ($i)$ext';
    }
    return p.join(dir.path, name);
  }

  Future<void> _finalizeIncoming(String transferId) async {
    final sink = _incomingSinks.remove(transferId);
    if (sink == null) return;

    await sink.close();
    _incomingFilePaths.remove(transferId);
    _incomingBytesReceived.remove(transferId);
    _updateTransferStatus(transferId, 'completed');
    final controller = _progressControllers.remove(transferId);
    if (controller != null) {
      controller.add(1.0);
      controller.close();
    }
    _transferDeviceIds.remove(transferId);
    _transferFileNames.remove(transferId);
    _transferFileSizes.remove(transferId);
    _transferDirections.remove(transferId);
    _notifyActiveTransfers();
  }

  void _cleanupIncomingTransfer(String transferId, String status) {
    final sink = _incomingSinks.remove(transferId);
    if (sink != null) {
      sink.close();
    }
    final filePath = _incomingFilePaths.remove(transferId);
    if (filePath != null) {
      try {
        File(filePath).deleteSync();
      } catch (_) {}
    }
    _incomingBytesReceived.remove(transferId);
    _updateTransferStatus(transferId, status);
    _progressControllers.remove(transferId)?.close();
    _transferDeviceIds.remove(transferId);
    _transferFileNames.remove(transferId);
    _transferFileSizes.remove(transferId);
    _transferDirections.remove(transferId);
    _notifyActiveTransfers();
    _pendingOffersNotifier.removeOffer(transferId);
  }
}
