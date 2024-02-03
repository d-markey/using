# Using

This package provides a `Releasable` mixin to upgrade classes with automatic
resource cleanup and finalization features.

## Examples

```dart
class Resource with Releasable {
  // manage resource

  @override
  void release() {
    // clean-up resource in this method
    // and make sure super.release() is called!
    super.release();
  }
}

void main() {
  try {
    final res = Resource(); // allocate
    // use resource
  } finally {
    // release in a finally block to ensure resources are released
    // even when an error occurs
    res.release();
  }
}
```

Extension methods are provided to support syntaxes similar to C#'s `using`
and Java's `try-with-resource`. They also help make sure resources are
properly released!

```dart
void main() {
  final data = Resource().use((res) {
    // use `res` to load and return some data
  });
  // the instance created by `Resource()` is guaranteed to be released

  final asyncData = await Resource().useAsync((res) async {
    // use `res` to load and return some data
  });
  // the instance created by `Resource()` is guaranteed to be released
}
```

Streams are also supported via the `consume()` extension method:

```dart
void main() {
  final outputs = await Resource().consume(inputStream, (res, input) async {
    // use `res` to process inputs and return outputs
  }).toList();
  // the instance created by `Resource()` is guaranteed to be released
}
```

Automatic finalization is also available to try ensure resources will be released
even in situations where `release()` has not been called. However, no promises are
made that this will really happen. For more information, see Dart's documentation
for [`Finalizer`](https://api.flutter.dev/flutter/dart-core/Finalizer-class.html).

```dart
class ResourceOwner with Releasable {
  final _res1 = Resource();
  final _res2 = Resource();

  ResourceOwner() {
    // non-deterministic clean-up relying on Dart's `Finalizer` class. If
    // the resource owner goes out of scope and `release()` was not called,
    // the two resources should eventually be released and reclaimed by a
    // `Finalizer`.
    autoRelease([_res1, _res2]);
  }

  // deterministic clean-up by explicitly calling `release()` on this
  // instance, or when the instance is used via extension methods (`use()`,
  // `consume()`...).
  @override
  void release() {
    // clean-up resources
    _res1.release();
    _res2.release();
    // call super method
    super.release();
  }
}
```
