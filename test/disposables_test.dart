import 'package:test/test.dart';
import 'package:using/using.dart';

import 'impl/bare_releasable.dart';
import 'impl/resource_owner.dart';

void main() {
  group('Releasables', () {
    test('properly release all instances', () {
      final releasables = [
        BareReleasable(),
        ResourceOwner(),
        BareReleasable(),
      ];
      for (var d in releasables) {
        expect(d.isReleased, isFalse);
      }
      releasables.release();
      for (var d in releasables) {
        expect(d.isReleased, isTrue);
      }
    });

    test('ignores null instances', () {
      final releasables = [
        BareReleasable(),
        null,
        null,
        ResourceOwner(),
        null,
        BareReleasable(),
      ];
      for (var d in releasables) {
        expect(d?.isReleased ?? false, isFalse);
      }
      releasables.release();
      for (var d in releasables) {
        expect(d?.isReleased ?? true, isTrue);
      }
    });
  });
}
