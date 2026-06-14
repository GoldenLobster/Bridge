import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/database/providers.dart';
import '../../core/providers/connection_providers.dart';
import '../../core/providers/device_list_provider.dart';
import '../../core/services/pairing_service_provider.dart';
import '../../shared/screens/paired_devices_screen.dart';

enum ScannerState { scanning, processing, error }

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  ScannerState _state = ScannerState.scanning;
  String _errorMessage = '';
  StreamSubscription<String>? _pairedSub;
  bool _handlingCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(connectionManagerProvider);
      ref.read(deviceListProvider.notifier);

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
    _pairedSub?.cancel();
    super.dispose();
  }

  Future<void> _startListeningForPairing() async {
    final pairingService =
        await ref.read(pairingServiceProvider.future);
    _pairedSub = pairingService.onPaired.listen((name) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PairedDevicesScreen(),
        ),
      );
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handlingCode) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handlingCode = true;

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      log('QrScannerScreen: invalid QR JSON: $e');
      _handlingCode = false;
      return;
    }

    final ip = data['ip'] as String?;
    final port = data['port'] as int?;
    if (ip == null || port == null || port == 0) {
      _handlingCode = false;
      return;
    }

    setState(() => _state = ScannerState.processing);

    _processQrCode(data);
  }

  Future<void> _processQrCode(Map<String, dynamic> data) async {
    final ip = data['ip'] as String;
    final port = data['port'] as int;
    final deviceId = data['deviceId'] as String? ?? '';

    try {
      final connectionManager = ref.read(connectionManagerProvider);
      final pairingService =
          await ref.read(pairingServiceProvider.future);

      await _startListeningForPairing();

      final session =
          await connectionManager.getOrCreateSession(deviceId, ip, port);
      await pairingService.initiateHandshake(session);
    } catch (e) {
      log('QrScannerScreen: failed to process QR code: $e');
      if (!mounted) return;
      setState(() {
        _state = ScannerState.error;
        _errorMessage = e.toString();
        _handlingCode = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _state = ScannerState.scanning;
      _errorMessage = '';
      _handlingCode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bridge')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case ScannerState.scanning:
        return MobileScanner(
          onDetect: _onDetect,
          errorBuilder: (context, error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Camera error: ${error.errorCode.message}'),
                ],
              ),
            );
          },
        );
      case ScannerState.processing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting and pairing...'),
            ],
          ),
        );
      case ScannerState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Failed to pair: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retry,
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
    }
  }
}
