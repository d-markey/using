import 'package:test/test.dart';

import 'impl/bare_releasable.dart';
import 'impl/resource_owner.dart';

void main() {
  group('Releasable', () {
    test('.isReleased == false on a fresh instance', () {
      final releasable = BareReleasable();
      expect(releasable.isReleased, isFalse);
    });

    test('.isReleased == true after a call to release()', () {
      final releasable = BareReleasable();
      releasable.release();
      expect(releasable.isReleased, isTrue);
    });

    test('supports multiple calls to release()', () {
      final bare = BareReleasable();
      expect(bare.isReleased, isFalse);
      bare.release();
      expect(bare.isReleased, isTrue);
      bare.release();
      expect(bare.isReleased, isTrue);

      var owner = ResourceOwner();
      expect(owner.isReleased, isFalse);
      expect(owner.exposedResource.isReleased, isFalse);
      owner.release();
      expect(owner.isReleased, isTrue);
      expect(owner.exposedResource.isReleased, isTrue);
      owner.release();
      expect(owner.isReleased, isTrue);
      expect(owner.exposedResource.isReleased, isTrue);

      owner = ResourceOwner();
      expect(owner.isReleased, isFalse);
      expect(owner.exposedResource.isReleased, isFalse);
      owner.exposedResource.release();
      expect(owner.isReleased, isFalse);
      expect(owner.exposedResource.isReleased, isTrue);
      owner.release();
      expect(owner.isReleased, isTrue);
      expect(owner.exposedResource.isReleased, isTrue);
    });
  });
}
