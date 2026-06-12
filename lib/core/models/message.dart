class Message {
  final String type;
  final String deviceId;
  final Map<String, dynamic> payload;

  const Message({
    required this.type,
    required this.deviceId,
    required this.payload,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      type: json['type'] as String,
      deviceId: json['deviceId'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'deviceId': deviceId,
      'payload': payload,
    };
  }
}
