import 'dart:convert';
import 'dart:typed_data';

import 'package:using/using.dart';

import 'impl/some_crypto_algorithm.dart';
import 'impl/utils.dart';

void main() {
  // enable tracking
  ReleasableTracker.enable();

  Uint8List hash;

  // bare use of `Releasable` where `release()` is called in a finally block
  final crypto = SomeCryptoAlgorithm();
  try {
    Print.blue('hashing...');
    crypto
      ..update(utf8.encode('password'))
      ..update(utf8.encode('salt'))
      ..update(utf8.encode('secret message'));
    hash = crypto.digest();
  } finally {
    crypto.release();
  }

  print('');

  // check
  Print.blue(
      '''crypto ${crypto.isReleased ? 'has been' : 'has not been'} released.
crypto ${crypto.hasBeenCleanedup ? 'has been' : 'has not been'} cleaned up.
hash = ${dumpBytes(hash)}''');
  try {
    crypto.update(utf8.encode('will throw'));
    Print.red('! Implementation error: update() was called successfully.');
  } on ReleasedException catch (ex) {
    Print.green('Implementation success: update() failed: $ex');
  }

  // report
  Print.std('Tracked count = ${ReleasableTracker.releasables.length}');
}
