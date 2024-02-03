// this class is a sample implementation which is not crytpographically secure
// do not use this class in production
import 'dart:typed_data';

import 'package:using/using.dart';

class SomeCryptoAlgorithm with Releasable {
  SomeCryptoAlgorithm() {
    track();
  }

  // this buffer may contain sensitive data, the release() method will make
  // sure it is cleared when the instance is released.
  final _sensitiveData = Uint8List(32);
  var _idx = 0;

  // do something with the data
  void update(Uint8List data) {
    if (isReleased) throw ReleasedException();
    for (var byte in data) {
      _sensitiveData[_idx] ^= byte;
      _idx = (_idx + 1) % 32;
    }
  }

  // compute the digest
  Uint8List digest() {
    if (isReleased) throw ReleasedException();
    final digest = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      digest[i] = _sensitiveData[i] ^ _sensitiveData[i + 16];
    }
    return digest;
  }

  bool get hasBeenCleanedup => _sensitiveData.every((byte) => byte == 0);

  void cleanup() {
    _sensitiveData.fillRange(0, _sensitiveData.length, 0);
  }

  @override
  void release() {
    try {
      // clear sensitive data
      cleanup();
    } catch (_) {
      // avoid throwing in release() method
    } finally {
      // call super.release()
      super.release();
    }
  }
}
