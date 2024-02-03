import 'releasable.dart';

extension Releasables on Iterable<Releasable?> {
  void release() {
    for (var releasable in this) {
      releasable?.release();
    }
  }
}

extension Releasables2 on (Releasable?, Releasable?) {
  void release() {
    $2?.release();
    $1?.release();
  }
}
