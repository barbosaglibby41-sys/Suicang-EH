import 'package:dio/dio.dart';

import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/gallery/domain/entities/gallery_key.dart';
import 'eh_request_policy.dart';
import 'network_exception.dart';

class SiteHttpClient {
  SiteHttpClient({
    required Dio dio,
    required AuthRepository authRepository,
    EhRequestPolicy requestPolicy = const EhRequestPolicy(),
  })  : _dio = dio,
        _authRepository = authRepository,
        _requestPolicy = requestPolicy;

  final Dio _dio;
  final AuthRepository _authRepository;
  final EhRequestPolicy _requestPolicy;

  Future<Response<List<int>>> getBytes(
    Uri url, {
    required SiteSource source,
    Uri? referer,
    bool acceptsImages = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final cookies = await _authRepository.cookiesFor(source);
      final response = await _dio.get<List<int>>(
        url.toString(),
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          headers: _requestPolicy.headers(
            source: source,
            cookies: cookies,
            referer: referer,
            acceptsImages: acceptsImages,
          ),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final status = response.statusCode;
      if (status == 401) {
        throw const NetworkException(
          kind: NetworkFailureKind.authenticationRequired,
          message: 'The site requires an authenticated session.',
          statusCode: 401,
        );
      }
      if (status == 403) {
        throw const NetworkException(
          kind: NetworkFailureKind.accessDenied,
          message: 'The site denied this request.',
          statusCode: 403,
        );
      }
      if (status == null || status < 200 || status >= 400) {
        throw NetworkException(
          kind: NetworkFailureKind.invalidResponse,
          message: 'Unexpected HTTP status.',
          statusCode: status,
        );
      }
      final setCookies = response.headers.map['set-cookie'] ?? const [];
      final updates = _requestPolicy.parseSetCookie(setCookies, source: source);
      if (updates.isNotEmpty) {
        await _authRepository.replaceCookies(updates);
      }
      return response;
    } on NetworkException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error) {
      throw NetworkException(
        kind: NetworkFailureKind.unknown,
        message: 'The request failed unexpectedly.',
        cause: error,
      );
    }
  }

  Future<String> getText(
    Uri url, {
    required SiteSource source,
    Uri? referer,
    CancelToken? cancelToken,
  }) async {
    final response = await getBytes(
      url,
      source: source,
      referer: referer,
      cancelToken: cancelToken,
    );
    final body = response.data;
    if (body == null) {
      throw const NetworkException(
        kind: NetworkFailureKind.invalidResponse,
        message: 'The site returned an empty response.',
      );
    }
    return String.fromCharCodes(body);
  }

  NetworkException _mapDioError(DioException error) {
    final kind = switch (error.type) {
      DioExceptionType.cancel => NetworkFailureKind.cancelled,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        NetworkFailureKind.timeout,
      DioExceptionType.connectionError => NetworkFailureKind.noConnection,
      DioExceptionType.badResponse => NetworkFailureKind.invalidResponse,
      _ => NetworkFailureKind.unknown,
    };
    return NetworkException(
      kind: kind,
      message: 'Network request failed.',
      statusCode: error.response?.statusCode,
      cause: error,
    );
  }
}
