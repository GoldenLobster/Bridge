import 'dart:async';
import 'dart:developer';

import '../models/message.dart';

/// Routes incoming [Message] objects to registered handler functions by message type and exposes a broadcast stream of all messages for general observation.
class MessageRouter {
  final Map<String, void Function(Message, String)> _handlers = {};
  final StreamController<({Message message, String sourceDeviceId})>
      _eventsController =
      StreamController<({Message message, String sourceDeviceId})>.broadcast();

  Stream<({Message message, String sourceDeviceId})> get events =>
      _eventsController.stream;

  void register(String type, void Function(Message, String) handler) {
    _handlers[type] = handler;
  }

  void route(Message message, String sourceDeviceId) {
    _eventsController
        .add((message: message, sourceDeviceId: sourceDeviceId));

    final handler = _handlers[message.type];
    if (handler != null) {
      handler(message, sourceDeviceId);
    } else {
      log('Warning: No handler registered for message type: ${message.type}');
    }
  }

  void dispose() {
    _eventsController.close();
  }
}
