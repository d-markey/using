import 'dart:math';

import 'package:using/using.dart';

import 'utils.dart';

class ReadOnlyResource with Releasable {
  ReadOnlyResource(this.name) : super() {
    track();
    Resource.unreleasedCount++;
  }

  final String name;

  Future<int> read() async {
    await randomDelay();
    final data = Random().nextInt(256);
    Print.gray('Reading from $name: $data...');
    return data;
  }

  @override
  void release() {
    if (!isReleased) {
      Resource.unreleasedCount--;
      Print.yellow('Releasing $this (remaining = ${Resource.unreleasedCount})');
    }
    super.release();
  }

  @override
  String toString() => name;
}

class WriteOnlyResource with Releasable {
  WriteOnlyResource(this.name) : super() {
    track();
    Resource.unreleasedCount++;
  }

  final String name;

  Future<void> write(int data) async {
    Print.gray('Writing to $name: $data...');
    await randomDelay();
  }

  @override
  void release() {
    if (!isReleased) {
      Resource.unreleasedCount--;
      Print.yellow('Releasing $this (remaining = ${Resource.unreleasedCount})');
    }
    super.release();
  }

  @override
  String toString() => name;
}

class Resource with Releasable implements ReadOnlyResource, WriteOnlyResource {
  static int unreleasedCount = 0;

  Resource(this.name) : super() {
    track();
    unreleasedCount++;
  }

  @override
  final String name;

  @override
  Future<int> read() async {
    await randomDelay();
    final data = Random().nextInt(256);
    Print.gray('Reading from $name: $data...');
    return data;
  }

  @override
  Future<void> write(int data) async {
    Print.gray('Writing to $name: $data...');
    await randomDelay();
  }

  @override
  void release() {
    if (!isReleased) {
      unreleasedCount--;
      Print.yellow('Releasing $this (remaining = $unreleasedCount)');
    }
    super.release();
  }

  @override
  String toString() => '$runtimeType $name ($hashCode)';
}
