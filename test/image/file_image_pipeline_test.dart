import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/authentication/domain/entities/session_cookie.dart';
import 'package:suicang_eh/core/image/image_decoder.dart';
import 'package:suicang_eh/core/image/image_pipeline.dart';
import 'package:suicang_eh/core/image/image_request.dart';
import 'package:suicang_eh/core/network/site_http_client.dart';
import 'package:suicang_eh/features/authentication/data/datasources/secure_cookie_store.dart';
import 'package:suicang_eh/features/authentication/data/repositories/secure_auth_repository.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';

void main() {
  test('reads offline file requests without starting a network request',
      () async {
    final directory = await Directory.systemTemp.createTemp('taro-reader-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/page.jpg');
    await file.writeAsBytes([1, 2, 3]);
    final client = SiteHttpClient(
      dio: Dio(),
      authRepository: SecureAuthRepository(_MemoryCookieStore()),
    );
    final pipeline = ImagePipeline(
      client: client,
      decoder: _PassthroughDecoder(),
    );

    final data = await pipeline.load(
      ImageRequest(url: file.uri, variant: ImageVariant.reader),
      source: SiteSource.eHentai,
    );

    expect(data, [1, 2, 3]);
  });
}

class _MemoryCookieStore implements SecureCookieStore {
  @override
  Future<void> clear() async {}

  @override
  Future<List<SessionCookie>> readAll() async => const [];

  @override
  Future<void> writeAll(Iterable<SessionCookie> cookies) async {}
}

class _PassthroughDecoder extends ImageDecoder {
  _PassthroughDecoder();

  @override
  Future<DecodedImage> decode(
    Uint8List source, {
    required int targetPixels,
  }) async =>
      DecodedImage(bytes: source, width: 1, height: source.length);
}
