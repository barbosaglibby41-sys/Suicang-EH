import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';
import 'package:suicang_eh/features/settings/domain/entities/site_preferences.dart';

void main() {
  test('updates only selected site source', () {
    const initial = SitePreferences();
    final updated = initial.copyWith(source: SiteSource.exHentai);

    expect(updated.source, SiteSource.exHentai);
  });
}
