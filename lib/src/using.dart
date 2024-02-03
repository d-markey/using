import 'dart:async';

import 'exceptions.dart';
import 'releasable.dart';

extension Using<T extends Releasable> on T {
  /// Calls [process] with the current [Releasable] instance and make sure it
  /// is released after processing completes. Returns the value returned by
  /// `process(this)`. [process] is called in the context of a new [Zone]. If
  /// the [Releasable] instance has been released, this method throws a
  /// [ReleasedException].
  R use<R>(R Function(T) process) => runZoned(() {
        if (isReleased) {
          throw ReleasedException();
        }
        try {
          // get and return result.
          final res = process(this);
          if (res is Future) {
            print('\u001B[31mprocess() returned a Future with use\u001B[0m');
          }
          return res;
        } finally {
          // it is the responsibility of implementers to make sure `release()`
          // does not throw.
          release();
        }
      });

  /// Calls [asyncProcess] with the current [Releasable] instance and make sure
  /// it is released after processing completes. Returns the value returned by
  /// `asyncProcess(this)`. [asyncProcess] is called in the context of a new
  /// [Zone]. If the [Releasable] instance has been released, this method throws
  /// a [ReleasedException].
  Future<R> useAsync<R>(Future<R> Function(T) asyncProcess) =>
      runZoned(() async {
        if (isReleased) {
          throw ReleasedException();
        }
        try {
          // return result when it is available.
          return await asyncProcess(this);
        } finally {
          // it is the responsibility of implementers to make sure `release()`
          // does not throw.
          release();
        }
      });
}

extension UsingAsync<T extends Releasable> on FutureOr<T> {
  /// Calls [process] with the future [Releasable] instance and make sure it
  /// is released after processing completes. Returns the value returned by
  /// `process(this)`. If the [Releasable] instance has been released, this
  /// method throws a [ReleasedException].
  Future<R> use<R>(R Function(T) process) => runZoned(() async {
        T? resource;
        try {
          // get and return result.
          resource = await this;
          if (resource.isReleased) {
            resource = null;
            throw ReleasedException();
          }
          final res = process(resource);
          if (res is Future) {
            print('\u001B[31mprocess() returned a Future with use\u001B[0m');
          }
          return res;
        } finally {
          // it is the responsibility of implementers to make sure `release()`
          // does not throw.
          resource?.release();
        }
      });

  /// Calls [asyncProcess] with the future [Releasable] instance and make sure
  /// it is released after processing completes. Returns the value returned by
  /// `asyncProcess(this)`. If the [Releasable] instance has been released, this
  /// method throws a [ReleasedException].
  Future<R> useAsync<R>(Future<R> Function(T) asyncProcess) =>
      runZoned(() async {
        T? resource;
        try {
          // return result when it is available.
          resource = await this;
          if (resource.isReleased) {
            resource = null;
            throw ReleasedException();
          }
          return await asyncProcess(resource);
        } finally {
          // it is the responsibility of implementers to make sure `release()`
          // does not throw.
          resource?.release();
        }
      });
}

extension Using2<T extends Releasable, U extends Releasable> on (T, U) {
  /// Calls [process] with the [Releasable] instances of this 2-uple and make
  /// sure they are released after processing completes. Returns the value
  /// returned by `process($1, $2)`. If any [Releasable] instance has been
  /// released, this method throws a [ReleasedException].
  R use<R>(R Function(T, U) process) => runZoned(() {
        if ($1.isReleased || $2.isReleased) {
          throw ReleasedException();
        }
        try {
          // get and return result.
          final res = process($1, $2);
          if (res is Future) {
            print('\u001B[31mprocess() returned a Future with use\u001B[0m');
          }
          return res;
        } finally {
          release();
        }
      });

  /// Calls [asyncProcess] with the [Releasable] instances of this 2-upple and
  /// make sure they are released after processing completes. Returns the value
  /// returned by `asyncProcess($1, $2)`. If any [Releasable] instance has been
  /// released, this method throws a [ReleasedException].
  Future<R> useAsync<R>(Future<R> Function(T, U) asyncProcess) =>
      runZoned(() async {
        if ($1.isReleased || $2.isReleased) {
          throw ReleasedException();
        }
        try {
          // return result when it is available.
          return await asyncProcess($1, $2);
        } finally {
          release();
        }
      });

  void release() {
    // it is the responsibility of implementers to make sure `release()`
    // does not throw.
    $1.release();
    $2.release();
  }
}
