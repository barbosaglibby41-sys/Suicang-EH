import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/favorites/data/datasources/cloud_favorites_parser.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';

void main() {
  test('parses categories, galleries and next page without account data', () {
    final html = File('test/fixtures/cloud_favorites.html').readAsStringSync();
    const parser = CloudFavoritesParser();
    final page = parser.parse(
      html: html,
      source: SiteSource.eHentai,
      baseUri: Uri.parse('https://e-hentai.org/'),
    );

    expect(page.categories.map((item) => item.name), ['Default', 'Artists']);
    expect(page.galleries.single.title, 'Saved & Gallery');
    expect(page.galleries.single.key.stableId, 'e-hentai:101');
    expect(page.nextUrl?.queryParameters['next'], '321');
  });
}
