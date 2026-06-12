import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:bridge/core/models/message.dart';
import 'package:bridge/core/networking/message_framer.dart';

void main() {
  group('MessageFramer', () {
    final testMessage = Message(
      type: 'ping',
      deviceId: 'abc-123',
      payload: {'seq': 1},
    );

    group('encode', () {
      test('produces correct length prefix and JSON body', () {
        final bytes = MessageFramer.encode(testMessage);

        expect(bytes.length, greaterThan(4));

        final length = ByteData.sublistView(bytes).getUint32(0, Endian.big);
        expect(length, bytes.length - 4);

        final json = String.fromCharCodes(bytes, 4);
        final decoded = Message.fromJson(jsonDecode(json) as Map<String, dynamic>);
        expect(decoded.type, 'ping');
        expect(decoded.deviceId, 'abc-123');
        expect(decoded.payload, {'seq': 1});
      });
    });

    group('decoder', () {
      test('single message encodes and decodes correctly', () async {
        final bytes = MessageFramer.encode(testMessage);
        final stream = Stream.fromIterable([bytes]);
        final results = await stream.transform(MessageFramer.decoder()).toList();

        expect(results.length, 1);
        expect(results[0].type, 'ping');
        expect(results[0].deviceId, 'abc-123');
        expect(results[0].payload, {'seq': 1});
      });

      test('message split across multiple byte chunks is reassembled', () async {
        final bytes = MessageFramer.encode(testMessage);
        final chunks = <Uint8List>[
          bytes.sublist(0, 2),
          bytes.sublist(2),
        ];
        final stream = Stream.fromIterable(chunks);
        final results = await stream.transform(MessageFramer.decoder()).toList();

        expect(results.length, 1);
        expect(results[0].type, 'ping');
        expect(results[0].deviceId, 'abc-123');
      });

      test('multiple messages in a single chunk are all emitted', () async {
        final msg1 = testMessage;
        final msg2 = Message(
          type: 'pong',
          deviceId: 'xyz-789',
          payload: {'ok': true},
        );
        final combined = Uint8List.fromList([
          ...MessageFramer.encode(msg1),
          ...MessageFramer.encode(msg2),
        ]);
        final stream = Stream.fromIterable([combined]);
        final results = await stream.transform(MessageFramer.decoder()).toList();

        expect(results.length, 2);
        expect(results[0].type, 'ping');
        expect(results[0].deviceId, 'abc-123');
        expect(results[1].type, 'pong');
        expect(results[1].deviceId, 'xyz-789');
        expect(results[1].payload, {'ok': true});
      });
    });
  });
}
