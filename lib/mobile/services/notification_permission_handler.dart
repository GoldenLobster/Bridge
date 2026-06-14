import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../../core/services/app_settings.dart';

/// Checks on Android whether notification listener access is granted and shows a one-time dialog prompting the user to enable it in system settings.
class NotificationPermissionHandler {
  final AppSettings _settings;

  NotificationPermissionHandler(this._settings);

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      return await NotificationListenerService.isPermissionGranted();
    } catch (_) {
      return true;
    }
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      return await NotificationListenerService.requestPermission();
    } catch (_) {
      return false;
    }
  }

  Future<void> checkAndShowDialog(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final alreadyShown = await _settings.get('shownNotificationAccessPrompt');
    if (alreadyShown == 'true') return;

    await _settings.set('shownNotificationAccessPrompt', 'true');

    final granted = await hasPermission();
    if (granted) return;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Bridge'),
        content: const Text(
          'Notification access lets Bridge mirror your phone notifications '
          'to your desktop so you never miss a message.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () async {
              await requestPermission();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
