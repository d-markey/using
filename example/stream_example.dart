import 'dart:typed_data';

import 'package:using/using.dart';

import 'impl/some_crypto_algorithm.dart';
import 'impl/stream_of_messages.dart';
import 'impl/utils.dart';

void main() async {
  // enable tracking
  ReleasableTracker.enable();

  final count = 10 + rnd.nextInt(90);
  Print.std('emitting $count messages');

  final stream = SomeCryptoAlgorithm().consume(
    messageStream(count, pausable: false),
    (crypto, message) async {
      Print.blue('hashing ${message.length} bytes...');
      await randomDelay(factor: 100);
      crypto.cleanup();
      crypto.update(message);
      return crypto.digest();
    },
  );

  // report: should have one tracked instance
  Print.std('Tracked count = ${ReleasableTracker.releasables.length}');

  List<Uint8List>? hashes;
  try {
    hashes = await stream.toList();
  } catch (ex) {
    Print.red('exception caught: $ex');
  }
  Print.green('received ${hashes?.length ?? 0}/$count messages');
  Print.std('');

  // report
  Print.std('Tracked count = ${ReleasableTracker.releasables.length}');
}
