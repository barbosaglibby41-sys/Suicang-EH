import '../../../gallery/domain/entities/gallery_key.dart';
import '../entities/auth_session.dart';
import '../entities/session_cookie.dart';

abstract interface class AuthRepository {
  Stream<AuthSession> watchSession();
  Future<AuthSession> currentSession();
  Future<void> importCookieHeader(String header);
  Future<void> replaceCookies(Iterable<SessionCookie> cookies);
  Future<void> removeCookiesByName(Iterable<String> names);
  Future<List<SessionCookie>> cookiesFor(SiteSource source);
  Future<void> clearSession();
}
