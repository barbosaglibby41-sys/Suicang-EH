import '../../../../core/network/network_exception.dart';
import '../../../../core/network/site_http_client.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../domain/entities/session_cookie.dart';
import '../../domain/entities/session_validation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/session_service.dart';

class EhSessionService implements SessionService {
  EhSessionService({
    required SiteHttpClient client,
    required AuthRepository authRepository,
  })  : _client = client,
        _authRepository = authRepository;

  final SiteHttpClient _client;
  final AuthRepository _authRepository;

  @override
  Future<SessionValidation> validate(SiteSource source) async {
    final session = await _authRepository.currentSession();
    if (!session.isAuthenticatedFor(source)) {
      return SessionValidation(
        source: source,
        status: SessionValidationStatus.authenticationRequired,
        message: '尚未保存可用于该站点的登录会话。',
      );
    }
    try {
      await _client.getText(_base(source), source: source);
      return SessionValidation(
          source: source, status: SessionValidationStatus.valid);
    } on NetworkException catch (error) {
      return SessionValidation(
        source: source,
        status: error.kind == NetworkFailureKind.accessDenied
            ? SessionValidationStatus.accessDenied
            : error.kind == NetworkFailureKind.authenticationRequired
                ? SessionValidationStatus.authenticationRequired
                : SessionValidationStatus.failed,
        message: error.message,
      );
    } catch (_) {
      return SessionValidation(
        source: source,
        status: SessionValidationStatus.failed,
        message: '无法验证当前站点会话。',
      );
    }
  }

  @override
  Future<SessionValidation> refreshExHentaiSession() async {
    final session = await _authRepository.currentSession();
    if (!session.hasCredentials) {
      return const SessionValidation(
        source: SiteSource.exHentai,
        status: SessionValidationStatus.authenticationRequired,
        message: '请先导入或登录 E-Hentai 会话。',
      );
    }
    await _authRepository.removeCookiesByName(['igneous']);
    try {
      await _client.getText(_base(SiteSource.eHentai),
          source: SiteSource.eHentai);
      final publicCookies =
          await _authRepository.cookiesFor(SiteSource.eHentai);
      final copied = <SessionCookie>[];
      for (final cookie in publicCookies) {
        if (const {'ipb_member_id', 'ipb_pass_hash', 'sk', 'nw', 'datatags'}
            .contains(cookie.name.toLowerCase())) {
          copied.add(cookie.copyWith(domain: 'exhentai.org'));
        }
      }
      if (copied.isNotEmpty) await _authRepository.replaceCookies(copied);
      await _client.getText(_base(SiteSource.exHentai),
          source: SiteSource.exHentai);
      return await validate(SiteSource.exHentai);
    } on NetworkException catch (error) {
      return SessionValidation(
        source: SiteSource.exHentai,
        status: error.kind == NetworkFailureKind.accessDenied
            ? SessionValidationStatus.accessDenied
            : SessionValidationStatus.failed,
        message: error.message,
      );
    } catch (_) {
      return const SessionValidation(
        source: SiteSource.exHentai,
        status: SessionValidationStatus.failed,
        message: 'ExHentai 会话刷新失败。',
      );
    }
  }

  Uri _base(SiteSource source) => Uri.https(
        source == SiteSource.eHentai ? 'e-hentai.org' : 'exhentai.org',
        '/',
      );
}
