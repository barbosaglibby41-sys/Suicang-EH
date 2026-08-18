import '../../../gallery/domain/entities/gallery_key.dart';
import '../entities/session_validation.dart';

abstract interface class SessionService {
  Future<SessionValidation> validate(SiteSource source);
  Future<SessionValidation> refreshExHentaiSession();
}
