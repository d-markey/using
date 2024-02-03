import 'dart:convert';

import 'package:using/using.dart';

import 'impl/some_crypto_algorithm.dart';
import 'impl/utils.dart';

void main() {
  // enable tracking
  ReleasableTracker.enable();

  final hash = SomeCryptoAlgorithm().use((crypto) {
    Print.blue('hashing...');
    crypto
      ..update(utf8.encode('password'))
      ..update(utf8.encode('salt'))
      ..update(utf8.encode('secret message'));
    return crypto.digest();
  });
  Print.green('hash = ${dumpBytes(hash)}');

  Print.std('');

  // report
  Print.std('Tracked count = ${ReleasableTracker.releasables.length}');
}
