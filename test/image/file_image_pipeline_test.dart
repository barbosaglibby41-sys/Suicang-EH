import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/authentication/domain/entities/session_cookie.dart';
import 'package:taro_eh_flutter/core/image/image_pipeline.dart';
import 'package:taro_eh_flutter/core/image/image_request.dart';
import 'package:taro_eh_flutter/core/network/site_http_client.dart';
import 'package:taro_eh_flutter/features/authentication/data/datasources/secure_cookie_store.dart';
import 'package:taro_eh_flutter/features/authentication/data/repositories/secure_auth_repository.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';

void main() {
  test('reads offline file requests without starting a network request', () async {
    final directory = await Directory.systemTemp.createTemp('taro-reader-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/page.jpg');
    await file.writeAsBytes([1, 2, 3]);
    final client = SiteHttpClient(
      dio: Dio(),
      authRepository: SecureAuthRepository(_MemoryCookieStore()),
    );
    final pipeline = ImagePipeline(client: client);

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
