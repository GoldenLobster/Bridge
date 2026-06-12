import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../models/message.dart';

class MessageFramer {
  MessageFramer._();

  static Uint8List encode(Message message) {
    final json = utf8.encode(jsonEncode(message.toJson()));
    final length = json.length;
    final result = Uint8List(4 + length);
    final data = ByteData.sublistView(result);
    data.setUint32(0, length, Endian.big);
    result.setRange(4, 4 + length, json);
    return result;
  }

  static StreamTransformer<Uint8List, Message> decoder() {
    final buffer = <int>[];
    return StreamTransformer<Uint8List, Message>.fromHandlers(
      handleData: (chunk, sink) {
        buffer.addAll(chunk);

        while (true) {
          if (buffer.length < 4) return;

          final length = ByteData.sublistView(Uint8List.fromList(buffer))
              .getUint32(0, Endian.big);

          if (buffer.length < 4 + length) return;

          final messageBytes = buffer.sublist(4, 4 + length);
          buffer.removeRange(0, 4 + length);

          final json = utf8.decode(messageBytes);
          final map = jsonDecode(json) as Map<String, dynamic>;
          sink.add(Message.fromJson(map));
        }
      },
      handleDone: (sink) {
        if (buffer.isNotEmpty) {
          throw StateError(
            'Stream ended with ${buffer.length} unprocessed byte(s) in buffer',
          );
        }
        sink.close();
      },
    );
  }
}
