import 'package:using/using.dart';

import 'impl/auto_releasable_resource_owner.dart';
import 'impl/resource.dart';
import 'impl/utils.dart';

void main() async {
  // make sure tracking is disabled as it would prevent finalization to happen!
  ReleasableTracker.disable();

  AutoReleasableResourceOwner? owner = AutoReleasableResourceOwner();
  await owner.useAsync((instance) async {
    Print.blue('Step 1: alive count = ${Resource.unreleasedCount}');
    await instance.doSomething();
    Print.blue('Step 2: alive count = ${Resource.unreleasedCount}');
    await instance.doSomething();
    Print.blue('Step 3: alive count = ${Resource.unreleasedCount}');
    await instance.done();
    Print.blue('Step 4: alive count = ${Resource.unreleasedCount}');
  });

  // make the owner unreachable...
  owner = null;

  // ... and give the GC a chance to trigger (?) so finalization can happen
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
