import 'dart:math';
import 'dart:typed_data';

String toHex(int byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}';

String dumpBytes(Uint8List bytes) => bytes.map(toHex).join(' ');

final rnd = Random();

Future randomDelay({int factor = 1}) =>
    Future.delayed(Duration(milliseconds: 5 + rnd.nextInt(45)) * factor);
