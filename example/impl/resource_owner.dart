import 'package:using/using.dart';

import 'resource.dart';

class ResourceOwner with Releasable {
  ResourceOwner() {
    track();
  }

  Resource? _a;
  Resource? _b;

  Future doSomething() async {
    // Intended resource leak: if resources were previously allocated,
    // these instances will become unreachable as 2 new instances are
    // allocated. Any previously allocated resource will not be released.
    _a = Resource('A');
    _b = Resource('B');
    // Do something with resources...
    var data = await _a!.read();
    await _b!.write(data);
  }

  Future wrapUp() async {
    await _b!.write(0);
  }

  @override
  void release() {
    try {
      // this will only release resources that are currently held by this
      // instance
      _a?.release();
      _b?.release();
    } finally {
      super.release();
    }
  }
}
