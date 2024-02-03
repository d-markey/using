import 'package:test/test.dart';
import 'package:using/using.dart';

import 'impl/bare_releasable.dart';
import 'impl/message_stream.dart';
import 'impl/resource_owner.dart';
import 'impl/utils.dart';

void main() {
  group('ReleasableTracker', () {
    test('is disabled by default', () {
      expect(ReleasableTracker.isEnabled, isFalse);
      expect(ReleasableTracker.releasables.length, 0);
    });

    test('does not track instances when disabled', () {
      expect(ReleasableTracker.isEnabled, isFalse);
      expect(ReleasableTracker.releasables.length, 0);

      final releasable = BareReleasable();
      expect(ReleasableTracker.releasables.length, 0);

      releasable.release();
      expect(ReleasableTracker.releasables.length, 0);
    });

    test('tracks instances when enabled', () {
      ReleasableTracker.enable();
      try {
        expect(ReleasableTracker.isEnabled, isTrue);
        expect(ReleasableTracker.releasables.length, 0);

        final bare = BareReleasable();
        expect(ReleasableTracker.releasables.length, 1);

        bare.release();
        expect(ReleasableTracker.releasables.length, 0);

        final owner = ResourceOwner();
        expect(ReleasableTracker.releasables.length, 2);

        owner.release();
        expect(ReleasableTracker.releasables.length, 0);
      } finally {
        ReleasableTracker.disable();
        expect(ReleasableTracker.isEnabled, isFalse);
      }
    });

    test('works with use()', () {
      ReleasableTracker.enable();
      try {
        expect(ReleasableTracker.isEnabled, isTrue);
        expect(ReleasableTracker.releasables.length, 0);

        BareReleasable().use((bare) {
          expect(ReleasableTracker.releasables.length, 1);
        });
        expect(ReleasableTracker.releasables.length, 0);

        ResourceOwner().use((owner) {
          expect(ReleasableTracker.releasables.length, 2);
        });
        expect(ReleasableTracker.releasables.length, 0);
      } finally {
        ReleasableTracker.disable();
        expect(ReleasableTracker.isEnabled, isFalse);
      }
    });

    test('works with useAsync()', () async {
      ReleasableTracker.enable();
      try {
        expect(ReleasableTracker.isEnabled, isTrue);
        expect(ReleasableTracker.releasables.length, 0);

        await BareReleasable().useAsync((bare) async {
          expect(ReleasableTracker.releasables.length, 1);
          await randomDelay(factor: 10);
          expect(ReleasableTracker.releasables.length, 1);
        });
        expect(ReleasableTracker.releasables.length, 0);

        await ResourceOwner().useAsync((owner) async {
          expect(ReleasableTracker.releasables.length, 2);
          await randomDelay(factor: 10);
          expect(ReleasableTracker.releasables.length, 2);
        });
        expect(ReleasableTracker.releasables.length, 0);
      } finally {
        ReleasableTracker.disable();
        expect(ReleasableTracker.isEnabled, isFalse);
      }
    });

    test('works with consume()', () async {
      ReleasableTracker.enable();
      try {
        expect(ReleasableTracker.isEnabled, isTrue);
        expect(ReleasableTracker.releasables.length, 0);

        final total = 7;
        var processed = 0;
        final indexes = await BareReleasable().consume(messageStream(total),
            (bare, msg) async {
          final idx = ++processed;
          expect(ReleasableTracker.releasables.length, 1);
          await Future.delayed(const Duration(milliseconds: 50));
          expect(ReleasableTracker.releasables.length, 1);
          return idx;
        }).toList();
        expect(ReleasableTracker.releasables.length, 0);

        expect(processed, total);
        expect(indexes, equals(List.generate(total, (i) => i + 1)));

        processed = 0;
        indexes.clear();
        indexes.addAll(await ResourceOwner().consume(messageStream(total),
            (owner, msg) async {
          final idx = ++processed;
          expect(ReleasableTracker.releasables.length, 2);
          await Future.delayed(const Duration(milliseconds: 50));
          expect(ReleasableTracker.releasables.length, 2);
          return idx;
        }).toList());
        expect(ReleasableTracker.releasables.length, 0);

        expect(processed, total);
        expect(indexes, equals(List.generate(total, (i) => i + 1)));
      } finally {
        ReleasableTracker.disable();
        expect(ReleasableTracker.isEnabled, isFalse);
      }
    });
  });
}
