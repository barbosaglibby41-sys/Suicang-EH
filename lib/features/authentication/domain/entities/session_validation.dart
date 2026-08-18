import '../../../gallery/domain/entities/gallery_key.dart';

enum SessionValidationStatus {
  valid,
  authenticationRequired,
  accessDenied,
  failed
}

class SessionValidation {
  const SessionValidation({
    required this.source,
    required this.status,
    this.message,
  });

  final SiteSource source;
  final SessionValidationStatus status;
  final String? message;
}
