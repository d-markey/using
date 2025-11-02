import 'package:meta/meta.dart';

import 'releasable_tracker.dart';

/// Mixin for [Releasable] objects.
/// Implementations can call the [track] method to make sure instances are
/// tracked (more information at [ReleasableTracker.enable]). The [release]
/// method allows for implementations to clean-up resources when objects are
/// eventually released.
mixin Releasable {
  /// Implementations should call this method e.g. at construction time to make
  /// sure they will be trackable in debugging scenarios. See [ReleasableTracker.enable]
  /// for more information.
  void track() {
    ReleasableTracker.startTracking(this);
  }

  bool _released = false;

  /// Returns `true` if the instance has been released, `false` otherwise.
  bool get isReleased => _released;

  /// The [release] method must be overriden in derived classes to clean up
  /// any resources they use. Implementations should not throw and must call
  /// `super.release()` in a `finally` block. If a derived class defines
  /// [Releasable] fields, these fields should be released of in this method.
  /// Note for implementers: it should be safe to call this method several
  /// times.
  @mustCallSuper
  void release() {
    _released = true;
    _token = Object();
    ReleasableTracker.stopTracking(this);
  }

  /// Internal token used with finalization. This could be used to remove
  /// attachments from the finalizer, however I fear that detaching may
  /// actually lead to resource leaks in certain scenarios. So it's only used
  /// for attaching at the moment.
  Object _token = Object();

  /// The [autoRelease] method is used to register a set of [Releasable]
  /// instances that will be automatically released when this instance becomes
  /// unreachable. Please note that this mechanism is based on Dart's [Finalizer]
  /// feature which makes no guarantee that it will ever be called. Depending
  /// on instance dependencies and their relationship with the internal [Finalizer]
  /// instance, it may even never be called. For instance, make sure `this` is
  /// never passed to [autoRelease] as this will create a cyclic graph of
  /// dependencies that will prevent finalization to happen.
  void autoRelease(List<Releasable?> instances) {
    for (var instance in instances.whereType<Releasable>()) {
      print('tag $instance for auto-release');
      _finalizer.attach(_token, instance, detach: _token);
    }
  }

  static final _finalizer = Finalizer<Releasable>((instance) {
    print('finalize $instance');
    instance.release();
  });
}
