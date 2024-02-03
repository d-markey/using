import 'dart:async';
import 'dart:typed_data';

import 'utils.dart';

Stream<Uint8List> messageStream(int count,
    {bool pausable = false, bool mayFail = false}) {
  int pauseCount = 0;
  Completer? pauseCompleter;
  late final StreamController<Uint8List> controller;

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

  void close() {
    if (!controller.isClosed) {
      controller.close();
    }
  }

  void sendMessages() {
    List<int> generator(int len) => List.generate(len, (_) => rnd.nextInt(256));

    final messages = <Future<void>>[];

    while (count-- > 0) {
      final len = 8 + rnd.nextInt(120);
      if (mayFail && len % 42 == 0) {
        messages.add(randomDelay().then((_) async {
          final pauseFuture = pauseCompleter?.future;
          if (pauseFuture != null) {
            await pauseFuture;
          }
          if (!controller.isClosed) {
            controller.addError(
              Exception('The meaning of life: shit happens!'),
              StackTrace.current,
            );
          }
        }));
      } else {
        messages.add(randomDelay().then((_) async {
          final pauseFuture = pauseCompleter?.future;
          if (pauseFuture != null) {
            await pauseFuture;
          }
          if (!controller.isClosed) {
            controller.add(Uint8List.fromList(generator(len)));
          }
        }));
      }
    }

    Future.wait(messages).then((_) => close());
  }

  controller = StreamController<Uint8List>(
    onListen: sendMessages,
    onCancel: () => close(),
    onPause: pause,
    onResume: resume,
  );

  return controller.stream;
}
