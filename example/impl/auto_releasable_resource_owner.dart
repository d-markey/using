import 'package:using/using.dart';

import 'resource.dart';

class AutoReleasableResourceOwner with Releasable {
  AutoReleasableResourceOwner() {
    track();
  }

  Resource? _a;
  Resource? _b;

  Future doSomething() async {
    // if _a and _b were previously allocated, this would create a resource
    // leak as they become unreachable and replaced by 2 new fresh instances
    _a = Resource('A');
    _b = Resource('B');
    // however, this can be worked around by calling autoRelease() so that all
    // resources allocated by this object are marked for auto-release when the
    // object becomes unreachable -- please note that Dart's runtime makes no
    // promises that finalization will ever happen
    autoRelease([_a, _b]);
    // Do something with resources...
    var data = await _a!.read();
    await _b!.write(data);
  }

  Future done() async {
    await _b!.write(0);
  }

  @override
  void release() {
    try {
      // this will only release resources that are currently held by this
      // instance
      print('Releasing _a & _b');
      _a?.release();
      _b?.release();
    } finally {
      super.release();
    }
  }
}
