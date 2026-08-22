import 'dart:convert';

import 'package:dio/dio.dart';

import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/gallery/domain/entities/gallery_key.dart';
import 'eh_request_policy.dart';
import 'network_exception.dart';
import 'network_retry_policy.dart';
import 'request_coalescer.dart';

class SiteHttpClient {
  SiteHttpClient({
    required Dio dio,
    required AuthRepository authRepository,
    EhRequestPolicy requestPolicy = const EhRequestPolicy(),
    RequestCoalescer<String, Response<List<int>>>? coalescer,
    NetworkRetryPolicy retryPolicy = const NetworkRetryPolicy(),
  })  : _dio = dio,
        _authRepository = authRepository,
        _requestPolicy = requestPolicy,
        _coalescer =
            coalescer ?? RequestCoalescer<String, Response<List<int>>>(),
        _retryPolicy = retryPolicy;

  final Dio _dio;
  final AuthRepository _authRepository;
  final EhRequestPolicy _requestPolicy;
  final RequestCoalescer<String, Response<List<int>>> _coalescer;
  final NetworkRetryPolicy _retryPolicy;

  Future<Response<List<int>>> getBytes(
    Uri url, {
    required SiteSource source,
    Uri? referer,
    bool acceptsImages = false,
    CancelToken? cancelToken,
  }) {
    if (cancelToken != null) {
      return _getBytesUncoalesced(
        url,
        source: source,
        referer: referer,
        acceptsImages: acceptsImages,
        cancelToken: cancelToken,
      );
    }
    final key = [
      url.toString(),
      source.storageValue,
      referer?.toString() ?? '',
      acceptsImages,
    ].join('|');
    return _coalescer.run(
      key,
      () => _retryPolicy.run(
        () => _getBytesUncoalesced(
          url,
          source: source,
          referer: referer,
          acceptsImages: acceptsImages,
        ),
      ),
    );
  }

  Future<Response<List<int>>> _getBytesUncoalesced(
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

  Future<Response<Map<String, dynamic>>> postJson(
    Uri url, {
    required SiteSource source,
    required Map<String, dynamic> data,
    Uri? referer,
    CancelToken? cancelToken,
  }) async {
    try {
      final cookies = await _authRepository.cookiesFor(source);
      final response = await _dio.post<Map<String, dynamic>>(
        url.toString(),
        data: data,
        cancelToken: cancelToken,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
          headers: _requestPolicy.headers(
            source: source,
            cookies: cookies,
            referer: referer,
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
      if (updates.isNotEmpty) await _authRepository.replaceCookies(updates);
      return response;
    } on NetworkException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Future<void> postForm(
    Uri url, {
    required SiteSource source,
    required Uri referer,
    required Map<String, String> data,
    CancelToken? cancelToken,
  }) async {
    try {
      final cookies = await _authRepository.cookiesFor(source);
      final response = await _dio.post<void>(
        url.toString(),
        data: data,
        cancelToken: cancelToken,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: _requestPolicy.headers(
            source: source,
            cookies: cookies,
            referer: referer,
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
    } on NetworkException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
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
    return utf8.decode(body, allowMalformed: true);
  }

  NetworkException _mapDioError(DioException error) {
    final kind = switch (error.type) {
      DioExceptionType.cancel => NetworkFailureKind.cancelled,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        NetworkFailureKind.timeout,
      DioExceptionType.connectionError => NetworkFailureKind.noConnection,
      DioExceptionType.badResponse => (error.response?.statusCode ?? 0) >= 500
          ? NetworkFailureKind.transient
          : NetworkFailureKind.invalidResponse,
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
