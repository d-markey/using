import 'package:test/test.dart';
import 'package:using/using.dart';

import 'impl/resource_owner.dart';
import 'impl/utils.dart';

void main() {
  group('Using', () {
    test('use() provides the expected instance', () {
      final owner = ResourceOwner();
      var ok = false;
      owner.use((instance) {
        expect(instance, equals(owner));
        ok = true;
      });
      expect(ok, isTrue);
    });

    test('use() properly releases the instance', () {
      final owner = ResourceOwner();
      var ok = false;
      owner.use((instance) {
        expect(instance.isReleased, isFalse);
        expect(instance.exposedResource.isReleased, isFalse);
        ok = true;
      });
      expect(ok, isTrue);
      expect(owner.isReleased, isTrue);
      expect(owner.exposedResource.isReleased, isTrue);
    });

    test('useAsync() provides the expected instance', () async {
      final owner = ResourceOwner();
      var ok = false;
      await owner.useAsync((instance) async {
        await randomDelay(factor: 10);
        expect(instance, equals(owner));
        ok = true;
      });
      expect(ok, isTrue);
    });

    test('useAsync() properly releases the instance', () async {
      final owner = ResourceOwner();
      var ok = false;
      await owner.useAsync((instance) async {
        await randomDelay(factor: 10);
        expect(instance.isReleased, isFalse);
        expect(instance.exposedResource.isReleased, isFalse);
        ok = true;
      });
      expect(ok, isTrue);
      expect(owner.isReleased, isTrue);
      expect(owner.exposedResource.isReleased, isTrue);
    });
  });
}
