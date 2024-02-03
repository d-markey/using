import 'package:using/using.dart';

import 'impl/resource.dart';
import 'impl/resource_owner.dart';
import 'impl/utils.dart';

void main() async {
  // do not enable tracking
  // ReleasableTracker.enable();

  // instantiate a releasable object
  await ResourceOwner().useAsync((owner) async {
    Print.blue('Step 1: alive count = ${Resource.unreleasedCount}');
    await owner.doSomething();
    Print.blue('Step 2: alive count = ${Resource.unreleasedCount}');
    await owner.doSomething();
    Print.blue('Step 3: alive count = ${Resource.unreleasedCount}');
    await owner.wrapUp();
    Print.blue('Step 4: alive count = ${Resource.unreleasedCount}');
  });

  await randomDelay(factor: 25);

  Print.std('Alive resources: ${Resource.unreleasedCount}');
  Print.std('');

  // if finalization happened, there will be no resource leak
  final stillAlive = Resource.unreleasedCount;
  if (stillAlive > 0) {
    Print.red('Resource leak! Still alive count = $stillAlive');
  } else {
    Print.green('No resource leak');
  }
}
