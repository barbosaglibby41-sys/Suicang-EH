import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/reading_progress_repository.dart';

class DriftReadingProgressRepository implements ReadingProgressRepository {
  DriftReadingProgressRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<ReadingProgress?> watch(GalleryKey key) {
    return (_database.select(_database.readingProgressEntries)
          ..where(
            (table) =>
                table.source.equals(key.source.storageValue) &
                table.gid.equals(key.gid),
          ))
        .watchSingleOrNull()
        .map(_fromRow);
  }

  @override
  Future<ReadingProgress?> get(GalleryKey key) async {
    final row = await (_database.select(_database.readingProgressEntries)
          ..where(
            (table) =>
                table.source.equals(key.source.storageValue) &
                table.gid.equals(key.gid),
          ))
        .getSingleOrNull();
    return _fromRow(row);
  }

  @override
  Future<void> save(ReadingProgress progress) {
    return _database
        .into(_database.readingProgressEntries)
        .insertOnConflictUpdate(
          ReadingProgressEntriesCompanion.insert(
            source: progress.galleryKey.source.storageValue,
            gid: progress.galleryKey.gid,
            pageIndex: progress.pageIndex,
            pageCount: progress.pageCount,
            updatedAt: progress.updatedAt.toUtc(),
          ),
        );
  }

  @override
  Future<void> clear(GalleryKey key) {
    return (_database.delete(_database.readingProgressEntries)
          ..where(
            (table) =>
                table.source.equals(key.source.storageValue) &
                table.gid.equals(key.gid),
          ))
        .go();
  }

  ReadingProgress? _fromRow(ReadingProgressEntry? row) {
    if (row == null) return null;
    return ReadingProgress(
      galleryKey: GalleryKey(
        source: SiteSource.fromStorageValue(row.source),
        gid: row.gid,
      ),
      pageIndex: row.pageIndex,
      pageCount: row.pageCount,
      updatedAt: row.updatedAt,
    );
  }
}
