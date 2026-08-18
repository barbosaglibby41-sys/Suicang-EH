import '../../../gallery/domain/entities/gallery_key.dart';

class SessionCookie {
  const SessionCookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.path,
    required this.updatedAt,
    this.expiresAt,
    this.secure = true,
    this.httpOnly = false,
  });

  final String name;
  final String value;
  final String domain;
  final String path;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final bool secure;
  final bool httpOnly;

  bool get isExpired => expiresAt?.isBefore(DateTime.now().toUtc()) ?? false;

  bool matches(SiteSource source) {
    final host = source == SiteSource.eHentai ? 'e-hentai.org' : 'exhentai.org';
    final normalized = domain.toLowerCase().replaceFirst(RegExp(r'^\.'), '');
    return host == normalized || host.endsWith('.$normalized');
  }

  SessionCookie copyWith({
    String? value,
    String? domain,
    String? path,
    DateTime? updatedAt,
    DateTime? expiresAt,
    bool? secure,
    bool? httpOnly,
  }) {
    return SessionCookie(
      name: name,
      value: value ?? this.value,
      domain: domain ?? this.domain,
      path: path ?? this.path,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      secure: secure ?? this.secure,
      httpOnly: httpOnly ?? this.httpOnly,
    );
  }
}
