import 'dart:async';
import 'dart:io';

import '../models/message.dart';
import 'message_framer.dart';

/// Wraps a [Socket] and pipes its raw byte stream through [MessageFramer] to emit decoded [Message] objects on a buffered stream.
class ConnectionSession {
  final Socket _socket;
  final StreamController<Message> _messageController;
  StreamSubscription<Message>? _subscription;
  bool _closed = false;

  ConnectionSession(this._socket)
      : _messageController = StreamController<Message>() {
    _subscription = _socket
        .transform(MessageFramer.decoder())
        .listen(
          _messageController.add,
          onError: (error) {
            if (!_closed) _messageController.addError(error);
          },
          onDone: () {
            if (!_closed) _messageController.close();
          },
        );
  }

  Stream<Message> get messages => _messageController.stream;

  void send(Message message) {
    if (_closed) return;
    final bytes = MessageFramer.encode(message);
    _socket.add(bytes);
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _subscription?.cancel();
    _socket.close();
    if (!_messageController.isClosed) {
      _messageController.close();
    }
  }
}
