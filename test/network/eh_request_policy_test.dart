import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/network/eh_request_policy.dart';
import 'package:suicang_eh/features/authentication/domain/entities/session_cookie.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';

void main() {
  const policy = EhRequestPolicy();

  test('uses only matching source cookies in the request header', () {
    final now = DateTime.utc(2026, 8, 19);
    final headers = policy.headers(
      source: SiteSource.exHentai,
      cookies: [
        SessionCookie(
          name: 'ipb_member_id',
          value: '100',
          domain: 'exhentai.org',
          path: '/',
          updatedAt: now,
        ),
        SessionCookie(
          name: 'public_only',
          value: 'nope',
          domain: 'e-hentai.org',
          path: '/',
          updatedAt: now,
        ),
      ],
    );

    expect(headers['Cookie'], 'ipb_member_id=100');
    expect(headers['User-Agent'], contains('iPhone'));
  });

  test('keeps a Set-Cookie update structured and scoped', () {
    final now = DateTime.utc(2026, 8, 19);
    final cookies = policy.parseSetCookie(
      ['igneous=valid; Path=/; Domain=.exhentai.org; Secure; HttpOnly'],
      source: SiteSource.exHentai,
      now: now,
    );

    expect(cookies.single.name, 'igneous');
    expect(cookies.single.domain, 'exhentai.org');
    expect(cookies.single.secure, isTrue);
    expect(cookies.single.httpOnly, isTrue);
  });
}
