import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/network/network_exception.dart';
import 'package:suicang_eh/core/network/site_http_client.dart';
import 'package:suicang_eh/features/authentication/data/datasources/secure_cookie_store.dart';
import 'package:suicang_eh/features/authentication/data/repositories/secure_auth_repository.dart';
import 'package:suicang_eh/features/gallery/data/repositories/eh_gallery_interaction_repository.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';

void main() {
  test('rejects comments shorter than three characters', () async {
    final repository = EhGalleryInteractionRepository(
      client: SiteHttpClient(
        dio: Dio(),
        authRepository: SecureAuthRepository(_MemoryCookieStore()),
      ),
    );
    const gallery = Gallery(
      key: GalleryKey(source: SiteSource.eHentai, gid: 1),
      title: 'Example',
      pageCount: 1,
      sourceUrl: Uri.parse('https://e-hentai.org/g/1/token/'),
    );

    await expectLater(
      repository.postComment(gallery: gallery, content: 'x'),
      throwsA(isA<NetworkException>()),
    );
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
