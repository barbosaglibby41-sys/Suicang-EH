import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/core/image/image_pipeline.dart';
import 'package:taro_eh_flutter/core/image/image_request.dart';
import 'package:taro_eh_flutter/core/network/site_http_client.dart';
import 'package:taro_eh_flutter/features/authentication/data/datasources/secure_cookie_store.dart';
import 'package:taro_eh_flutter/features/authentication/data/repositories/secure_auth_repository.dart';
import 'package:taro_eh_flutter/features/authentication/domain/entities/session_cookie.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';

void main() {
  test('coalesces concurrent requests for the same cache key', () async {
    final dio = Dio();
    var calls = 0;
    dio.httpClientAdapter = _CountingAdapter(() async {
      calls += 1;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return ResponseBody.fromBytes([1, 2, 3], 200,
          headers: {
            Headers.contentTypeHeader: ['image/jpeg'],
          });
    });
    final client = SiteHttpClient(
      dio: dio,
      authRepository: SecureAuthRepository(_MemoryStore()),
    );
    final pipeline = ImagePipeline(client: client);
    const request = ImageRequest(
      url: Uri.parse('https://image.example/a.jpg'),
      targetPixels: 720,
    );

    final results = await Future.wait([
      pipeline.load(request, source: SiteSource.eHentai),
      pipeline.load(request, source: SiteSource.eHentai),
    ]);

    expect(calls, 1);
    expect(results, everyElement(isA<Uint8List>()));
  });
}

class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.handler);

  final Future<ResponseBody> Function() handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler();

  @override
  void close({bool force = false}) {}
}

class _MemoryStore implements SecureCookieStore {
  @override
  Future<void> clear() async {}

  @override
  Future<List<SessionCookie>> readAll() async => const [];

  @override
  Future<void> writeAll(Iterable<SessionCookie> cookies) async {}
}
