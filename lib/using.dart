/// **Using**
///
/// This package provides a `Releasable` mixin to upgrade classes with automatic
/// resource cleanup and finalization features.
///
/// ```
/// class Resource with Releasable {
///   // manage resource
///
///   @override
///   void release() {
///     // clean-up resource
///     super.release();
///   }
/// }
///
/// void main() {
///   Resource? res;
///   try {
///     res = Resource(); // allocate
///     // use resource
///   } finally {
///     res?.release(); // release
///   }
/// }
/// ```
///
/// Extension methods are provided to support syntaxes similar to C#'s `using`
/// and Java's `try-with-resource`. They also help make sure resources are
/// properly released!
///
/// ```
/// void main() {
///   final data = Resource().use((res) {
///     // use `res` to load and return some data
///   });
///   // the instance created by `Resource()` is now released
///
///   final asyncData = await Resource().useAsync((res) async {
///     // use `res` to load and return some data
///   });
///   // the instance created by `Resource()` is now released
/// }
/// ```
///
/// Streams are also supported via the `consume()` extension method:
///
/// ```
/// void main() {
///   final outputs = await Resource().consume(inputStream, (res, input) async {
///     // use `res` to process inputs and return outputs
///   }).toList();
///   // the instance created by `Resource()` is now released
/// }
/// ```
///
/// Automatic finalization is also available to try ensure resources will be released
/// even in situations where `release()` has not been called. However, no promises are
/// made that this will really happen, see the Dart documentation for the `Finalizer`
/// class.
///
/// ```
/// class ResourceOwner with Releasable {
///   final _res1 = Resource();
///   final _res2 = Resource();
///
///   ResourceOwner() {
///     // non-deterministic clean-up relying on Dart's `Finalizer` feature. If
///     // the resource owner goes out of scope and `release()` was not called,
///     // the two resources should eventually be released and reclaimed by a
///     // Finalizer.
///     autoRelease([_res1, _res2]);
///   }
///
///   // deterministic clean-up by explicitly calling `release()` or using the
///   // extension methods (`use()`, `consume()`...).
///   @override
///   void release() {
///     // clean-up resources
///     _res1.release();
///     _res2.release();
///     // call super method
///     super.release();
///   }
/// }
/// ```
library;

export 'src/exceptions.dart';
export 'src/releasable.dart';
export 'src/releasable_tracker.dart';
export 'src/releasables.dart';
export 'src/streaming.dart';
export 'src/using.dart';
