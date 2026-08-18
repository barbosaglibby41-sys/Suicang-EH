import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_tag.dart';

void main() {
  group('GalleryKey', () {
    test('is stable across equivalent source and gid values', () {
      const first = GalleryKey(source: SiteSource.eHentai, gid: 4117420);
      const second = GalleryKey(source: SiteSource.eHentai, gid: 4117420);

      expect(first, second);
      expect(first.stableId, 'e-hentai:4117420');
    });

    test('separates identical gids from different sources', () {
      const publicKey = GalleryKey(source: SiteSource.eHentai, gid: 1);
      const privateKey = GalleryKey(source: SiteSource.exHentai, gid: 1);

      expect(publicKey, isNot(privateKey));
    });
  });

  group('GalleryTag', () {
    test('parses namespaced values without losing the raw syntax', () {
      final tag = GalleryTag.parse('artist:example');

      expect(tag.namespace, 'artist');
      expect(tag.key, 'example');
      expect(tag.rawName, 'artist:example');
    });
  });
}
