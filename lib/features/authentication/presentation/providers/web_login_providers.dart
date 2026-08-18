import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/web_login_cookie_bridge.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_providers.dart';

final webLoginCookieBridgeProvider = Provider<WebLoginCookieBridge>((ref) {
  return NativeWebLoginCookieBridge();
});

final webLoginServiceProvider = Provider<WebLoginService>((ref) {
  return WebLoginService(
    bridge: ref.watch(webLoginCookieBridgeProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

class WebLoginService {
  WebLoginService({
    required WebLoginCookieBridge bridge,
    required AuthRepository authRepository,
  })  : _bridge = bridge,
        _authRepository = authRepository;

  final WebLoginCookieBridge _bridge;
  final AuthRepository _authRepository;

  Future<void> authenticate() async {
    final cookies = await _bridge.authenticate(
      initialUrl:
          Uri.parse('https://forums.e-hentai.org/index.php?act=Login&CODE=00'),
    );
    if (cookies.isEmpty) {
      throw StateError(
          'Native login did not capture an authenticated session.');
    }
    await _authRepository.replaceCookies(cookies);
  }
}
