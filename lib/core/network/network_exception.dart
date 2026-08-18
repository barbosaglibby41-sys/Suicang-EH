import '../errors/app_exception.dart';

enum NetworkFailureKind {
  cancelled,
  timeout,
  noConnection,
  authenticationRequired,
  accessDenied,
  invalidResponse,
  parseFailure,
  transient,
  unknown,
}

class NetworkException extends AppException {
  const NetworkException({
    required this.kind,
    required super.message,
    this.statusCode,
    super.cause,
  });

  final NetworkFailureKind kind;
  final int? statusCode;
}
