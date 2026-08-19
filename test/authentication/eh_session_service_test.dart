import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/authentication/data/datasources/secure_cookie_store.dart';
import 'package:suicang_eh/features/authentication/data/repositories/secure_auth_repository.dart';
import 'package:suicang_eh/features/authentication/domain/entities/session_cookie.dart';

void main() {
  test('removes stale igneous values from every logical domain', () async {
    final store = _MemoryCookieStore();
    final repository = SecureAuthRepository(store);
    final now = DateTime.utc(2026, 8, 19);
    await repository.replaceCookies([
      SessionCookie(
          name: 'igneous',
          value: 'old',
          domain: 'e-hentai.org',
          path: '/',
          updatedAt: now),
      SessionCookie(
          name: 'igneous',
          value: 'old',
          domain: 'exhentai.org',
          path: '/',
          updatedAt: now),
      SessionCookie(
          name: 'ipb_member_id',
          value: '1',
          domain: 'e-hentai.org',
          path: '/',
          updatedAt: now),
    ]);

    await repository.removeCookiesByName(['igneous']);

    final session = await repository.currentSession();
    expect(session.cookies.map((cookie) => cookie.name), ['ipb_member_id']);
    await repository.dispose();
  });
}

class _MemoryCookieStore implements SecureCookieStore {
  List<SessionCookie> values = const [];

  @override
  Future<void> clear() async => values = const [];

  @override
  Future<List<SessionCookie>> readAll() async => values;

  @override
  Future<void> writeAll(Iterable<SessionCookie> cookies) async {
    values = List<SessionCookie>.unmodifiable(cookies);
  }
}
