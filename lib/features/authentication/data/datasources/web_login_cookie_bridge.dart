import '../../domain/entities/session_cookie.dart';

abstract interface class WebLoginCookieBridge {
  /// Presents the native web login flow and returns cookies captured by the
  /// platform cookie store, including HttpOnly cookies where supported.
  Future<List<SessionCookie>> authenticate({required Uri initialUrl});
}

class UnsupportedWebLoginCookieBridge implements WebLoginCookieBridge {
  const UnsupportedWebLoginCookieBridge();

  @override
  Future<List<SessionCookie>> authenticate({required Uri initialUrl}) {
    throw UnsupportedError('Native web login is not configured for this platform.');
  }
}
