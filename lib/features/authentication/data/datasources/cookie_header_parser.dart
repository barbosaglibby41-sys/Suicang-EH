import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/session_cookie.dart';

abstract final class CookieHeaderParser {
  static List<SessionCookie> parse(
    String header, {
    DateTime? now,
    Iterable<String> domains = const ['e-hentai.org', 'exhentai.org'],
  }) {
    final timestamp = (now ?? DateTime.now()).toUtc();
    final values = <String, String>{};

    for (final segment in header.split(';')) {
      final separator = segment.indexOf('=');
      if (separator <= 0) {
        continue;
      }
      final name = segment.substring(0, separator).trim();
      final value = segment.substring(separator + 1).trim();
      if (name.isEmpty || value.isEmpty || !_isValidName(name)) {
        continue;
      }
      values[name] = value;
    }

    if (values.isEmpty) {
      throw const ValidationException('No valid Cookie name=value pairs found.');
    }

    return [
      for (final domain in domains)
        for (final entry in values.entries)
          SessionCookie(
            name: entry.key,
            value: entry.value,
            domain: domain,
            path: '/',
            updatedAt: timestamp,
          ),
    ];
  }

  static bool _isValidName(String value) =>
      RegExp(r'^[!#$%&*+.^_`|~0-9A-Za-z-]+$').hasMatch(value);
}
