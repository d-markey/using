import 'dart:async';
import 'dart:typed_data';

import 'utils.dart';

Stream<Uint8List> messageStream(int count, {required bool pausable}) {
  final sw = Stopwatch()..start();

  int pauseCount = 0;
  Completer? pauseCompleter;

  void pause() {
    if (pausable) {
      pauseCompleter ??= Completer();
    }
    pauseCount++;
  }

  void resume() {
    pauseCount--;
    if (pauseCount == 0) {
      pauseCompleter?.complete();
      pauseCompleter = null;
    }
  }

  late final StreamController<Uint8List> controller;

  void close(String message) {
    if (!controller.isClosed) {
      Print.gray(message);
      controller.close();
    }
  }

  void sendMessages() {
    List<int> generator(int len) => List.generate(len, (_) => rnd.nextInt(256));

    final messages = <Future<void>>[];

    while (count-- > 0) {
      final len = 8 + rnd.nextInt(120);
      if (len % 42 == 0) {
        messages.add(randomDelay(factor: 100).then((_) async {
          final pauseFuture = pauseCompleter?.future;
          if (pauseFuture != null) {
            await pauseFuture;
          }
          if (!controller.isClosed) {
            Print.gray('${sw.elapsed} Emitting error');
            controller.addError(
              Exception('The meaning of life: shit happens!'),
              StackTrace.current,
            );
          }
        }));
      } else {
        messages.add(randomDelay(factor: 100).then((_) async {
          final pauseFuture = pauseCompleter?.future;
          if (pauseFuture != null) {
            await pauseFuture;
          }
          if (!controller.isClosed) {
            Print.gray('${sw.elapsed} Emitting $len bytes');
            controller.add(Uint8List.fromList(generator(len)));
          }
        }));
      }
    }

    Future.wait(messages)
        .then((_) => close('${sw.elapsed} All messages sent!'));
  }

  controller = StreamController<Uint8List>(
    onListen: sendMessages,
    onCancel: () => close('${sw.elapsed} Canceled!'),
    onPause: pause,
    onResume: resume,
  );

  return controller.stream;
}
