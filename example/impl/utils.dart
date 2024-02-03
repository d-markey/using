import 'dart:math';
import 'dart:typed_data';

String toHex(int byte, {int width = 2}) =>
    '0x${byte.toRadixString(16).padLeft(width, '0')}';

String dumpBytes(Uint8List bytes) => bytes.map(toHex).join(' ');

final rnd = Random();

Future randomDelay({int factor = 1}) =>
    Future.delayed(Duration(milliseconds: 5 + rnd.nextInt(45)) * factor);

class Print {
  static const _reset = '\u001B[0m';
  static const _red = '\u001B[31m';
  static const _green = '\u001B[32m';
  static const _yellow = '\u001B[33m';
  static const _blue = '\u001B[34m';
  static const _cyan = '\u001B[36m';
  static const _gray = '\u001B[90m';

  static void _print(String message) {
    print(message);
    // stdout.nonBlocking.add(utf8.encode('$message\n'));
    // stdout.writeln(message);
    // stdout.flush();
  }

  static void std(String message) => _print(message);

  static void red(String message) => _print('$_red$message$_reset');
  static void blue(String message) => _print('$_blue$message$_reset');
  static void green(String message) => _print('$_green$message$_reset');
  static void yellow(String message) => _print('$_yellow$message$_reset');
  static void cyan(String message) => _print('$_cyan$message$_reset');
  static void gray(String message) => _print('$_gray$message$_reset');
}
