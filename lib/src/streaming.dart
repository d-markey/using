import 'dart:async';

import 'exceptions.dart';
import 'releasable.dart';
import 'releasables.dart';

extension Streaming<T extends Releasable> on T {
  /// Consumes and process events of a [Stream] with the current [Releasable]
  /// instance and make sure it is released when all events have been consumed.
  /// Returns a [Stream] with values returned by `process(this, event)`. If the
  /// [Releasable] instance is released while processing events from [input],
  /// a [ReleasedException] will be sent to the output [Stream].
  Stream<X> consume<E, X>(
          Stream<E> input, FutureOr<X> Function(T, E) process) =>
      runZoned(() => _consume<E, X>(
            input,
            (event) {
              if (isReleased) {
                throw ReleasedException();
              }
              return process(this, event);
            },
            cleanup: release,
          ));
}

extension Streaming2<T extends Releasable, U extends Releasable> on (T, U) {
  /// Consumes and process events of a [Stream] with the [Releasable] instances
  /// of this 2-uple and make sure they are released when all events have been
  /// consumed. Returns a [Stream] with values returned by `process($1, $2,
  /// event)`. If any [Releasable] instance is released while processing events
  /// from [input], a [ReleasedException] will be sent to the output [Stream].
  Stream<X> consume<E, X>(
          Stream<E> input, FutureOr<X> Function(T, U, E) process) =>
      runZoned(() => _consume<E, X>(
            input,
            (event) {
              if ($1.isReleased || $2.isReleased) {
                throw ReleasedException();
              }
              return process($1, $2, event);
            },
            cleanup: release,
          ));
}

Stream<X> _consume<E, X>(
  Stream<E> input,
  FutureOr<X> Function(E) process, {
  required void Function() cleanup,
}) {
  StreamSubscription<E>? inputSubscription;
  late final StreamController<X> controller;

  final deferred = <Future>{};
  final bufferedEvents = <(X?, Object?, StackTrace?)>[];
  int pauseCount = 0;

  // forward errors
  void forwardErrors(Object error, StackTrace stackTrace) {
    if (!controller.isClosed) {
      if (pauseCount > 0) {
        bufferedEvents.add((null, error, stackTrace));
      } else {
        controller.addError(error, stackTrace);
      }
    }
  }

  // emit value, buffer if paused
  void emit(X value) {
    if (!controller.isClosed) {
      if (pauseCount > 0) {
        bufferedEvents.add((value, null, null));
      } else {
        controller.add(value);
      }
    }
  }

  // handle events
  void handleEvents(E event) {
    if (controller.isClosed) return;

    FutureOr<X> res;
    try {
      res = process(event);
    } catch (ex, st) {
      forwardErrors(ex, st);
      return;
    }

    if (res is Future<X>) {
      late final Future defer;
      defer = res.then((r) {
        deferred.remove(defer);
        emit(r);
      }, onError: (ex, st) {
        deferred.remove(defer);
        forwardErrors(ex, st);
      });
      deferred.add(defer);
    } else {
      emit(res);
    }
  }

  // pause
  void pause() {
    pauseCount++;
    inputSubscription?.pause();
  }

  // resume
  void resume() {
    if (pauseCount > 0) {
      pauseCount--;
      inputSubscription?.resume();
      if (pauseCount == 0) {
        if (!controller.isClosed) {
          // resume: emit events received while paused
          for (var i = 0; i < bufferedEvents.length; i++) {
            // non-null error =>     null value, non-null stackTrace
            //     null error => non-null value,     null stackTrace
            final (value, error, stackTrace) = bufferedEvents[i];
            if (error != null) {
              controller.addError(error, stackTrace!);
            } else {
              // ignore: null_check_on_nullable_type_parameter
              controller.add(value!);
            }
          }
        }
        // clear buffered events
        bufferedEvents.clear();
      }
    }
  }

  // wait for pending results to complete, then close the stream and cleanup
  void terminate() {
    inputSubscription?.cancel();
    Future.wait(deferred).whenComplete(() {
      controller.close();
      cleanup();
    });
  }

  // close the stream immediately and cleanup only after pending results are
  // complete (pending computations may require the context to still be
  // available)
  void cancelAndTerminate() {
    controller.close();
    inputSubscription?.cancel();
    Future.wait(deferred).whenComplete(() {
      cleanup();
    });
  }

  // subscribe to input stream
  void subscribe() {
    inputSubscription = input.listen(
      handleEvents,
      onError: forwardErrors,
      onDone: terminate,
      cancelOnError: false,
    );
  }

  controller = StreamController<X>(
    onListen: subscribe,
    onPause: pause,
    onResume: resume,
    onCancel: cancelAndTerminate,
  );

  return controller.stream;
}
