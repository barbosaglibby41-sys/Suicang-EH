import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/core/errors/app_exception.dart';
import 'package:taro_eh_flutter/features/authentication/data/datasources/cookie_header_parser.dart';

void main() {
  test('imports valid cookies to both supported site domains', () {
    final now = DateTime.utc(2026, 8, 19);
    final cookies = CookieHeaderParser.parse(
      'ipb_member_id=100; ipb_pass_hash=abc==; sk=token',
      now: now,
    );

    expect(cookies, hasLength(6));
    expect(
      cookies.where((cookie) => cookie.name == 'ipb_pass_hash').first.value,
      'abc==',
    );
    expect(cookies.map((cookie) => cookie.domain),
        containsAll(['e-hentai.org', 'exhentai.org']));
  });

  test('rejects input that contains no valid cookie pair', () {
    expect(
      () => CookieHeaderParser.parse('not a cookie; ; ='),
      throwsA(isA<ValidationException>()),
    );
  });
}
