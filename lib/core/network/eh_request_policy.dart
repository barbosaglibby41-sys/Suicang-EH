import '../../features/authentication/domain/entities/session_cookie.dart';
import '../../features/gallery/domain/entities/gallery_key.dart';

class EhRequestPolicy {
  const EhRequestPolicy();

  static const userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 Mobile';

  Map<String, String> headers({
    required SiteSource source,
    required Iterable<SessionCookie> cookies,
    Uri? referer,
    bool acceptsImages = false,
  }) {
    final active = <String, String>{};
    for (final cookie in cookies) {
      if (!cookie.isExpired && cookie.matches(source)) {
        active[cookie.name] = cookie.value;
      }
    }

    return {
      'User-Agent': userAgent,
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Accept': acceptsImages
          ? 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8'
          : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
      if (referer != null) 'Referer': referer.toString(),
      if (active.isNotEmpty)
        'Cookie': active.entries.map((entry) => '${entry.key}=${entry.value}').join('; '),
    };
  }

  List<SessionCookie> parseSetCookie(
    Iterable<String> values, {
    required SiteSource source,
    DateTime? now,
  }) {
    final timestamp = (now ?? DateTime.now()).toUtc();
    final output = <SessionCookie>[];

    for (final raw in values) {
      final fragments = raw.split(';');
      if (fragments.isEmpty) {
        continue;
      }
      final first = fragments.first.trim();
      final equals = first.indexOf('=');
      if (equals <= 0) {
        continue;
      }
      final attributes = <String, String>{};
      var secure = false;
      var httpOnly = false;
      for (final fragment in fragments.skip(1)) {
        final separator = fragment.indexOf('=');
        final key = (separator < 0 ? fragment : fragment.substring(0, separator))
            .trim()
            .toLowerCase();
        final value = separator < 0 ? '' : fragment.substring(separator + 1).trim();
        if (key == 'secure') secure = true;
        if (key == 'httponly') httpOnly = true;
        if (key.isNotEmpty) attributes[key] = value;
      }
      final defaultDomain = source == SiteSource.eHentai
          ? 'e-hentai.org'
          : 'exhentai.org';
      final expiry = _parseExpiry(attributes, timestamp);
      output.add(
        SessionCookie(
          name: first.substring(0, equals).trim(),
          value: first.substring(equals + 1).trim(),
          domain: attributes['domain']?.replaceFirst(RegExp(r'^\.'), '') ??
              defaultDomain,
          path: (attributes['path']?.isEmpty ?? true)
              ? '/'
              : attributes['path']!,
          updatedAt: timestamp,
          expiresAt: expiry,
          secure: secure,
          httpOnly: httpOnly,
        ),
      );
    }
    return output;
  }

  DateTime? _parseExpiry(Map<String, String> attributes, DateTime now) {
    final maxAge = int.tryParse(attributes['max-age'] ?? '');
    if (maxAge != null) {
      return now.add(Duration(seconds: maxAge));
    }
    final expires = attributes['expires'];
    return expires == null ? null : DateTime.tryParse(expires)?.toUtc();
  }
}
