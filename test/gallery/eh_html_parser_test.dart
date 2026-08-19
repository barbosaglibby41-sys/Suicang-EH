import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/gallery/data/datasources/eh_html_parser.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';

void main() {
  const parser = EhHtmlParser();
  final fixtureRoot = Directory.current.path;

  String fixture(String name) =>
      File('$fixtureRoot/test/fixtures/$name').readAsStringSync();

  test('parses and deduplicates gallery cards with the next cursor', () {
    final result = parser.galleriesPage(
      html: fixture('gallery_listing.html'),
      source: SiteSource.eHentai,
      baseUri: Uri.parse('https://e-hentai.org/'),
    );

    expect(result.galleries, hasLength(2));
    expect(result.galleries.first.key.stableId, 'e-hentai:101');
    expect(result.galleries.first.title, 'First & Gallery');
    expect(result.galleries.first.sourceUrl,
        Uri.parse('https://e-hentai.org/g/101/token-a/'));
    expect(result.galleries.first.thumbnailUrl,
        Uri.parse('https://thumb.example/101.jpg'));
    expect(result.galleries.first.category, 'Manga');
    expect(result.galleries.first.uploader, 'Sample Artist');
    expect(result.galleries.first.pageCount, 24);
    expect(result.galleries.first.rating, 4.5);
    expect(result.galleries.first.tags.single.rawName, 'artist:sample');
    expect(result.nextCursor, 987654);
    expect(parser.toplistNextPage(fixture('gallery_listing.html'), 0), 1);
  });

  test('parses gallery detail metadata, tags and ordered page links', () {
    const fallback = Gallery(
      key: GalleryKey(source: SiteSource.eHentai, gid: 101),
      title: 'Fallback',
      pageCount: 0,
    );
    final detail = parser.detail(
      html: fixture('gallery_detail.html'),
      fallback: fallback,
      sourceUri: Uri.parse('https://e-hentai.org/g/101/token-a/'),
      includePageLinks: true,
    );

    expect(detail.gallery.title, 'A & B Title');
    expect(detail.gallery.category, 'Doujinshi');
    expect(detail.gallery.uploader, 'Uploader Name');
    expect(detail.gallery.pageCount, 1234);
    expect(detail.gallery.tags.map((tag) => tag.rawName),
        ['artist:sample', 'female:example']);
    expect(detail.metadata.language, 'English');
    expect(detail.metadata.fileSize, '123 MB');
    expect(detail.metadata.favoriteCount, 456);
    expect(detail.metadata.ratingCount, 78);
    expect(detail.metadata.torrentUrl,
        Uri.parse('https://torrent.example/file.torrent'));
    expect(detail.comments.single.author, 'Uploader');
    expect(detail.comments.single.content, 'Hello\nworld');
    expect(detail.comments.single.isUploader, isTrue);
    expect(parser.commentVoteToken(fixture('gallery_detail.html')), 'abc123');
    expect(detail.previews.single.page, 1);
    expect(detail.previews.single.spriteUrl,
        Uri.parse('https://thumb.example/sprite.jpg'));
    expect(detail.previews.single.yOffset, 300);
    expect(detail.pageLinks.map((url) => url.path),
        ['/s/abc123/101-1', '/s/abc123/101-2']);
  });

  test('extracts the final readable image URL', () {
    final result = parser.resolveImageUrl(fixture('image_page.html'));

    expect(result, Uri.parse('https://image.example/full/1.jpg'));
  });
}
