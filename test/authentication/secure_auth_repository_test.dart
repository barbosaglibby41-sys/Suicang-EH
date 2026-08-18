import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/authentication/data/datasources/secure_cookie_store.dart';
import 'package:taro_eh_flutter/features/authentication/data/repositories/secure_auth_repository.dart';
import 'package:taro_eh_flutter/features/authentication/domain/entities/session_cookie.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';

void main() {
  test('merges updates and clears sessions without leaking values', () async {
    final store = _MemoryCookieStore();
    final repository = SecureAuthRepository(store);
    final now = DateTime.utc(2026, 8, 19);

    await repository.replaceCookies([
      SessionCookie(
        name: 'ipb_member_id',
        value: '100',
        domain: 'e-hentai.org',
        path: '/',
        updatedAt: now,
      ),
    ]);
    await repository.replaceCookies([
      SessionCookie(
        name: 'igneous',
        value: 'fresh',
        domain: 'exhentai.org',
        path: '/',
        updatedAt: now.add(const Duration(minutes: 1)),
      ),
    ]);

    final publicCookies = await repository.cookiesFor(SiteSource.eHentai);
    final privateCookies = await repository.cookiesFor(SiteSource.exHentai);
    expect(publicCookies, hasLength(1));
    expect(privateCookies, hasLength(1));

    await repository.clearSession();
    expect((await repository.currentSession()).cookies, isEmpty);
    await repository.dispose();
  });
}

class _MemoryCookieStore implements SecureCookieStore {
  List<SessionCookie> _cookies = const [];

  @override
  Future<void> clear() async => _cookies = const [];

  @override
  Future<List<SessionCookie>> readAll() async => _cookies;

  @override
  Future<void> writeAll(Iterable<SessionCookie> cookies) async {
    _cookies = List<SessionCookie>.unmodifiable(cookies);
  }
}
