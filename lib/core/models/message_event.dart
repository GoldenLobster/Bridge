import 'message.dart';

/// Bundles a received [Message] with the device ID of the device that sent it.
class MessageEvent {
  final Message message;
  final String sourceDeviceId;

  const MessageEvent(this.message, this.sourceDeviceId);
}
