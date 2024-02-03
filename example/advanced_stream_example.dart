import 'dart:async';
import 'dart:typed_data';

import 'package:using/using.dart';

import 'impl/some_crypto_algorithm.dart';
import 'impl/stream_of_messages.dart';
import 'impl/utils.dart';

void main() async {
  // enable tracking
  ReleasableTracker.enable();

  // process (with pausable / non-pausable stream)
  final count = 10 + rnd.nextInt(90);
  await process(count, pausable: false);
  // report
  Print.std('Tracked count = ${ReleasableTracker.releasables.length}');

  await process(count, pausable: true);
  // report
  Print.std('Tracked count = ${ReleasableTracker.releasables.length}');
}

Future process(int count, {required bool pausable}) async {
  Print.std(
      'Emitting $count messages with ${pausable ? 'pausable' : 'non-pausable'} input stream');
  final stream = SomeCryptoAlgorithm().consume(
    messageStream(count, pausable: pausable),
    (crypto, message) async {
      Print.blue('hashing ${message.length} bytes...');
      await randomDelay(factor: 100);
      if (rnd.nextInt(100) < 20) {
        // throw 20% random processing errors
        throw Exception('Computation error');
      }
      crypto.cleanup();
      crypto.update(message);
      return crypto.digest();
    },
  );

  // report: should have one tracked instance
  Print.std('Tracked count = ${ReleasableTracker.releasables.length}');

  final completer = Completer();
  final hashes = <Uint8List>[];
  final errors = <Object>[];

  final sub = stream.listen(
    (hash) => hashes.add(hash),
    onError: (err) {
      Print.red('ERROR $err');
      errors.add(err);
    },
    onDone: () => completer.complete(),
    cancelOnError: false,
  );

  Future.delayed(Duration(seconds: 2), () {
    Print.yellow('paused for 3 secs...');
    sub.pause();
    Future.delayed(Duration(seconds: 2), () {
      Print.yellow('resume');
      sub.resume();
    });
  });

  try {
    await completer.future;
  } catch (ex) {
    Print.red('exception caught: $ex');
  }

  Print.green(
      'received ${hashes.length} messages + ${errors.length} errors = $count events');
  Print.std('');
}
