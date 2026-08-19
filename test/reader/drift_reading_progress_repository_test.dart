import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/database/app_database.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';
import 'package:suicang_eh/features/reader/data/repositories/drift_reading_progress_repository.dart';
import 'package:suicang_eh/features/reader/domain/entities/reading_progress.dart';

void main() {
  late AppDatabase database;
  late DriftReadingProgressRepository repository;

  setUp(() {
    database = openTestDatabase(NativeDatabase.memory());
    repository = DriftReadingProgressRepository(database);
  });

  tearDown(() => database.close());

  test('upserts progress by stable source and gallery id', () async {
    const key = GalleryKey(source: SiteSource.exHentai, gid: 42);
    final time = DateTime.utc(2026, 8, 19);
    await repository.save(
      ReadingProgress(
        galleryKey: key,
        pageIndex: 3,
        pageCount: 20,
        updatedAt: time,
      ),
    );
    await repository.save(
      ReadingProgress(
        galleryKey: key,
        pageIndex: 4,
        pageCount: 20,
        updatedAt: time.add(const Duration(seconds: 1)),
      ),
    );

    final saved = await repository.get(key);
    expect(saved?.pageIndex, 4);
    expect(saved?.pageCount, 20);
  });

  test('keeps progress for same gid on distinct sources', () async {
    final time = DateTime.utc(2026, 8, 19);
    for (final source in SiteSource.values) {
      await repository.save(
        ReadingProgress(
          galleryKey: GalleryKey(source: source, gid: 7),
          pageIndex: 1,
          pageCount: 2,
          updatedAt: time,
        ),
      );
    }

    final rows = await database.select(database.readingProgressEntries).get();
    expect(rows, hasLength(2));
  });
}
