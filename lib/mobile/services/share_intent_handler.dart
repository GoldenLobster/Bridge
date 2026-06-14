import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../shared/screens/paired_devices_screen.dart';

/// Listens for files shared into Bridge from other apps via receive_sharing_intent and navigates to the paired devices screen with those files preloaded for sending.
class ShareIntentHandler {
  final GlobalKey<NavigatorState> navigatorKey;
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  ShareIntentHandler({required this.navigatorKey});

  void init() {
    try {
      ReceiveSharingIntent.instance.getInitialMedia().then((files) {
        final paths = _extractPaths(files);
        if (paths.isNotEmpty) {
          _navigateWithFiles(paths);
        }
        ReceiveSharingIntent.instance.reset();
      });

      _subscription =
          ReceiveSharingIntent.instance.getMediaStream().listen((files) {
        final paths = _extractPaths(files);
        if (paths.isNotEmpty) {
          _navigateWithFiles(paths);
        }
      });
    } catch (_) {
    }
  }

  List<String> _extractPaths(List<SharedMediaFile> files) {
    return files
        .map((f) => f.path)
        .where((p) => p.isNotEmpty)
        .toList();
  }

  void _navigateWithFiles(List<String> filePaths) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => PairedDevicesScreen(filePaths: filePaths),
      ),
      (route) => false,
    );
  }

  void dispose() {
    _subscription?.cancel();
    ReceiveSharingIntent.instance.reset();
  }
}
