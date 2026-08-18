import 'dart:async';

import '../../../gallery/domain/entities/gallery_key.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/session_cookie.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/cookie_header_parser.dart';
import '../datasources/secure_cookie_store.dart';

class SecureAuthRepository implements AuthRepository {
  SecureAuthRepository(this._store);

  final SecureCookieStore _store;
  final _controller = StreamController<AuthSession>.broadcast();
  AuthSession? _cached;

  @override
  Stream<AuthSession> watchSession() async* {
    yield await currentSession();
    yield* _controller.stream;
  }

  @override
  Future<AuthSession> currentSession() async {
    final cookies = await _store.readAll();
    final session = AuthSession(
      cookies: _active(cookies),
      updatedAt: _latestUpdate(cookies),
    );
    _cached = session;
    return session;
  }

  @override
  Future<void> importCookieHeader(String header) async {
    await replaceCookies(CookieHeaderParser.parse(header));
  }

  @override
  Future<void> replaceCookies(Iterable<SessionCookie> cookies) async {
    final merged = _merge(_cached?.cookies ?? await _store.readAll(), cookies);
    await _store.writeAll(merged);
    _emit(merged);
  }

  @override
  Future<List<SessionCookie>> cookiesFor(SiteSource source) async {
    final session = _cached ?? await currentSession();
    return session.cookies
        .where((cookie) => cookie.matches(source) && !cookie.isExpired)
        .toList(growable: false);
  }

  @override
  Future<void> clearSession() async {
    await _store.clear();
    _emit(const []);
  }

  List<SessionCookie> _merge(
    Iterable<SessionCookie> existing,
    Iterable<SessionCookie> updates,
  ) {
    final merged = <String, SessionCookie>{
      for (final cookie in existing.where((cookie) => !cookie.isExpired))
        _key(cookie): cookie,
    };
    for (final cookie in updates.where((cookie) => !cookie.isExpired)) {
      merged[_key(cookie)] = cookie;
    }
    return merged.values.toList(growable: false);
  }

  String _key(SessionCookie cookie) =>
      '${cookie.name.toLowerCase()}|${cookie.domain.toLowerCase()}|${cookie.path}';

  List<SessionCookie> _active(Iterable<SessionCookie> cookies) =>
      cookies.where((cookie) => !cookie.isExpired).toList(growable: false);

  DateTime? _latestUpdate(Iterable<SessionCookie> cookies) {
    DateTime? latest;
    for (final cookie in cookies) {
      if (latest == null || cookie.updatedAt.isAfter(latest)) {
        latest = cookie.updatedAt;
      }
    }
    return latest;
  }

  void _emit(List<SessionCookie> cookies) {
    final session = AuthSession(
      cookies: _active(cookies),
      updatedAt: _latestUpdate(cookies),
    );
    _cached = session;
    _controller.add(session);
  }

  Future<void> dispose() => _controller.close();
}
