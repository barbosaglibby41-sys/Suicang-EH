import 'package:taro_web_login_bridge/taro_web_login_bridge.dart';

import '../../domain/entities/session_cookie.dart';

abstract interface class WebLoginCookieBridge {
  /// Presents native WebView login and returns platform-captured cookies.
  Future<List<SessionCookie>> authenticate({required Uri initialUrl});
}

class NativeWebLoginCookieBridge implements WebLoginCookieBridge {
  NativeWebLoginCookieBridge({TaroWebLoginBridge? bridge})
      : _bridge = bridge ?? TaroWebLoginBridge();

  final TaroWebLoginBridge _bridge;

  @override
  Future<List<SessionCookie>> authenticate({required Uri initialUrl}) async {
    final cookies = await _bridge.authenticate(initialUrl: initialUrl);
    return [
      for (final cookie in cookies)
        SessionCookie(
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain,
          path: cookie.path,
          updatedAt: cookie.updatedAt,
          expiresAt: cookie.expiresAt,
          secure: cookie.secure,
          httpOnly: cookie.httpOnly,
        ),
    ];
  }
}
