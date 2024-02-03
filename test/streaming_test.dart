import 'package:test/test.dart';
import 'package:using/using.dart';

import 'impl/message_stream.dart';
import 'impl/resource_owner.dart';

void main() {
  group('Streaming', () {
    test('consume() provides the expected instance - sync processing',
        () async {
      final total = 7;
      final msgStream = messageStream(total);

      final owner = ResourceOwner();
      var count = 0;
      final counts = await owner.consume(msgStream, (instance, msg) {
        ++count;
        expect(instance, equals(owner));
        return count;
      }).toList();
      expect(counts.length, equals(total));
      expect(counts, equals(List.generate(total, (i) => i + 1)));
    });

    test('consume() properly releases the instance - sync processing',
        () async {
      final total = 7;
      final msgStream = messageStream(total);

      final owner = ResourceOwner();
      var count = 0;
      final counts = await owner.consume(msgStream, (instance, msg) {
        ++count;
        expect(instance.isReleased, isFalse);
        expect(instance.exposedResource.isReleased, isFalse);
        return count;
      }).toList();
      expect(counts.length, equals(total));
      expect(counts, equals(List.generate(total, (i) => i + 1)));
      expect(owner.isReleased, isTrue);
      expect(owner.exposedResource.isReleased, isTrue);
    });

    test('consume() provides the expected instance - async processing',
        () async {
      final total = 7;
      final msgStream = messageStream(total);

      final owner = ResourceOwner();
      var count = 0;
      final counts = await owner.consume(msgStream, (instance, msg) async {
        var curCount = ++count;
        await Future.delayed(const Duration(milliseconds: 10));
        expect(instance, equals(owner));
        return curCount;
      }).toList();
      expect(counts.length, equals(total));
      expect(counts, equals(List.generate(total, (i) => i + 1)));
    });

    test('consume() properly releases the instance - async processing',
        () async {
      final total = 7;
      final msgStream = messageStream(total);

      final owner = ResourceOwner();
      var count = 0;
      final counts = await owner.consume(msgStream, (instance, msg) async {
        var curCount = ++count;
        await Future.delayed(const Duration(milliseconds: 10));
        expect(instance.isReleased, isFalse);
        expect(instance.exposedResource.isReleased, isFalse);
        return curCount;
      }).toList();
      counts.sort();
      expect(counts.length, equals(total));
      expect(counts, equals(List.generate(total, (i) => i + 1)));
      expect(owner.isReleased, isTrue);
      expect(owner.exposedResource.isReleased, isTrue);
    });
  });
}
