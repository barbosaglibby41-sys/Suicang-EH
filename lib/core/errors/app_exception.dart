abstract class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

final class MigrationException extends AppException {
  const MigrationException(super.message, {super.cause});
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}
