import 'package:meta/meta.dart';

import 'releasable.dart';

/// Tracker for [Releasable] objects. By default, tracking is disabled.
class ReleasableTracker {
  static bool _enabled = false;

  /// `true` if tracking of [Releasable] objects is enabled, `false` otherwise.
  /// By default, tracking is disabled.
  static get isEnabled => _enabled;

  /// Enables tracking of [Releasable] objects. Please note that enabling
  /// tracking may result in increased memory usage as Dart's GC will not be
  /// able to clean up and reclaim instances of tracked objects unless they
  /// are properly released. [enable] should only be used for debugging purpose.
  /// Avoid using [enable] in production environments. Please note that tracking
  /// instances will also prevent [Releasable.autoRelease] to work since the
  /// tracking mechanism will keep a reference to all releasable instances; as
  /// a result, they will all remain reachable from Dart's perspective. By
  /// default, tracking is disabled.
  static void enable() => _enabled = true;

  /// Disables tracking of [Releasable] objects. By default, tracking is
  /// disabled.
  static void disable() => _enabled = false;

  /// List of tracked [Releasable] instances. Please note that tracking
  /// instances will prevent any finalization to happen!
  static final _releasables = <Releasable>{};

  /// Provides the list of [Releasable] instances that are still tracked.
  /// When a program terminates, this list should be empty to ensure all
  /// releasable objects have been released.
  static Iterable<Releasable> get releasables => _releasables.map(_self);

  @internal

  /// Start tracking a [Releasable] object.
  static void startTracking(Releasable instance) {
    if (_enabled) {
      _releasables.add(instance);
    }
  }

  @internal

  /// Stop tracking a [Releasable] object. This method is called by
  /// [Releasable.release] and `release()` methods of releasable objects
  /// should make sure they always call `super.release()`.
  static void stopTracking(Releasable instance) {
    _releasables.remove(instance);
  }
}

T _self<T>(T instance) => instance;
