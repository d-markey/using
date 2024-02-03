/// Implementers may use this exception to protect their code from being called
/// after a resource has been released.
class ReleasedException implements Exception {
  ReleasedException({this.message = 'Instance has been released.'});

  /// The error message.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
