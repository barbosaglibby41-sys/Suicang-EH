import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/database/app_database.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';
import 'package:suicang_eh/features/library/data/repositories/drift_library_repository.dart';

void main() {
  late AppDatabase database;
  late DriftLibraryRepository repository;
  const gallery = Gallery(
    key: GalleryKey(source: SiteSource.eHentai, gid: 42),
    title: 'Gallery',
    pageCount: 3,
  );

  setUp(() {
    database = openTestDatabase(NativeDatabase.memory());
    repository = DriftLibraryRepository(database);
  });

  tearDown(() => database.close());

  test('preserves favorite while recording history', () async {
    await repository.setFavorite(gallery, value: true);
    await repository.recordOpened(gallery);

    expect(await repository.isFavorite(gallery.key), isTrue);
    final history = await repository.watchHistory().first;
    expect(history.single.key, gallery.key);
  });

  test('preserves history while changing favorite', () async {
    await repository.recordOpened(gallery);
    await repository.setFavorite(gallery, value: true);

    final history = await repository.watchHistory().first;
    expect(history.single.key, gallery.key);
  });
}
