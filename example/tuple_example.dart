import 'package:using/using.dart';

import 'impl/resource.dart';

void main() async {
  await (ReadOnlyResource('reader'), WriteOnlyResource('writer'))
      .useAsync((reader, writer) async {
    final data = await reader.read();
    await writer.write(data);
  });
}
