import 'package:using/using.dart';

import 'bare_releasable.dart';

class ResourceOwner with Releasable {
  ResourceOwner() {
    track();
  }

  final _disposable = BareReleasable();

  Releasable get exposedResource => _disposable;

  @override
  void release() {
    try {
      _disposable.release();
    } finally {
      super.release();
    }
  }
}
