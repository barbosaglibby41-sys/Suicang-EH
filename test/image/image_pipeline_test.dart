import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/image/disk_image_cache.dart';
import 'package:suicang_eh/core/image/image_decoder.dart';
import 'package:suicang_eh/core/image/image_pipeline.dart';
import 'package:suicang_eh/core/image/image_request.dart';
import 'package:suicang_eh/core/network/site_http_client.dart';
import 'package:suicang_eh/features/authentication/data/datasources/secure_cookie_store.dart';
import 'package:suicang_eh/features/authentication/data/repositories/secure_auth_repository.dart';
import 'package:suicang_eh/features/authentication/domain/entities/session_cookie.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    final pipeline = ImagePipeline(
      client: client,
      diskCache: _MemoryDiskCache(),
      decoder: _PassthroughDecoder(),
    );
    final request = ImageRequest(
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

class _MemoryDiskCache extends DiskImageCache {
  _MemoryDiskCache() : super();

  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(ImageRequest request) async =>
      values[request.cacheKey];

  @override
  Future<void> write(ImageRequest request, List<int> bytes) async {
    values[request.cacheKey] = Uint8List.fromList(bytes);
  }
}

class _PassthroughDecoder extends ImageDecoder {
  _PassthroughDecoder();

  @override
  Future<DecodedImage> decode(
    Uint8List source, {
    required int targetPixels,
  }) async => DecodedImage(bytes: source, width: 1, height: source.length);
}
