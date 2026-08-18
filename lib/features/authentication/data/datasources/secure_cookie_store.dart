import '../../domain/entities/session_cookie.dart';

abstract interface class SecureCookieStore {
  Future<List<SessionCookie>> readAll();
  Future<void> writeAll(Iterable<SessionCookie> cookies);
  Future<void> clear();
}
