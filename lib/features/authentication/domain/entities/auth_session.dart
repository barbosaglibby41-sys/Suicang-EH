import '../../../gallery/domain/entities/gallery_key.dart';
import 'session_cookie.dart';

class AuthSession {
  const AuthSession({
    required this.cookies,
    required this.updatedAt,
  });

  const AuthSession.empty()
      : cookies = const [],
        updatedAt = null;

  final List<SessionCookie> cookies;
  final DateTime? updatedAt;

  bool get hasCredentials => cookies.any(
        (cookie) =>
            cookie.name == 'ipb_member_id' || cookie.name == 'ipb_pass_hash',
      );

  bool isAuthenticatedFor(SiteSource source) =>
      hasCredentials && cookies.any((cookie) => cookie.matches(source));
}
