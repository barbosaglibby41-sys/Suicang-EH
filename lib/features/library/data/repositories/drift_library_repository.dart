import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/domain/entities/gallery_tag.dart';
import '../../domain/repositories/library_repository.dart';

class DriftLibraryRepository implements LibraryRepository {
  DriftLibraryRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<Gallery>> watchFavorites() {
    final query = _database.select(_database.galleries).join([
      innerJoin(
        _database.libraryEntries,
        _database.libraryEntries.source.equalsExp(_database.galleries.source) &
            _database.libraryEntries.gid.equalsExp(_database.galleries.gid),
      ),
    ])
      ..where(_database.libraryEntries.isFavorite.equals(true))
      ..orderBy([OrderingTerm.desc(_database.libraryEntries.lastOpenedAt)]);
    return query.watch().map((rows) => rows.map(_galleryFromRow).toList());
  }

  @override
  Stream<List<Gallery>> watchHistory({int limit = 100}) {
    final query = _database.select(_database.galleries).join([
      innerJoin(
        _database.libraryEntries,
        _database.libraryEntries.source.equalsExp(_database.galleries.source) &
            _database.libraryEntries.gid.equalsExp(_database.galleries.gid),
      ),
    ])
      ..where(_database.libraryEntries.lastOpenedAt.isNotNull())
      ..orderBy([OrderingTerm.desc(_database.libraryEntries.lastOpenedAt)])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(_galleryFromRow).toList());
  }

  @override
  Future<bool> isFavorite(GalleryKey key) async {
    final entry = await (_database.select(_database.libraryEntries)
          ..where(
            (table) =>
                table.source.equals(key.source.storageValue) &
                table.gid.equals(key.gid),
          ))
        .getSingleOrNull();
    return entry?.isFavorite ?? false;
  }

  @override
  Future<void> setFavorite(Gallery gallery, {required bool value}) async {
    await _database.transaction(() async {
      await _upsertGallery(gallery);
      await _database.into(_database.libraryEntries).insertOnConflictUpdate(
            LibraryEntriesCompanion.insert(
              source: gallery.key.source.storageValue,
              gid: gallery.key.gid,
              isFavorite: Value(value),
              lastOpenedAt: const Value.absent(),
            ),
          );
    });
  }

  @override
  Future<void> recordOpened(Gallery gallery, {DateTime? openedAt}) async {
    await _database.transaction(() async {
      await _upsertGallery(gallery);
      await _database.into(_database.libraryEntries).insertOnConflictUpdate(
            LibraryEntriesCompanion.insert(
              source: gallery.key.source.storageValue,
              gid: gallery.key.gid,
              isFavorite: const Value.absent(),
              lastOpenedAt: Value(openedAt ?? DateTime.now().toUtc()),
            ),
          );
    });
  }

  @override
  Future<void> clearHistory() async {
    await _database.update(_database.libraryEntries).write(
          const LibraryEntriesCompanion(lastOpenedAt: Value(null)),
        );
  }

  Future<void> _upsertGallery(Gallery gallery) {
    return _database.into(_database.galleries).insertOnConflictUpdate(
          GalleriesCompanion.insert(
            source: gallery.key.source.storageValue,
            gid: gallery.key.gid,
            title: gallery.title,
            uploader: Value(gallery.uploader),
            category: Value(gallery.category),
            thumbnailUrl: Value(gallery.thumbnailUrl?.toString()),
            sourceUrl: Value(gallery.sourceUrl?.toString()),
            pageCount: Value(gallery.pageCount),
            tagsJson: Value(
              jsonEncode([
                for (final tag in gallery.tags)
                  {
                    'namespace': tag.namespace,
                    'key': tag.key,
                    'translatedName': tag.translatedName,
                  },
              ]),
            ),
            rating: Value(gallery.rating),
            postedAt: Value(gallery.postedAt),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Gallery _galleryFromRow(TypedResult row) {
    final value = row.readTable(_database.galleries);
    final decodedTags = jsonDecode(value.tagsJson) as List<dynamic>;
    return Gallery(
      key: GalleryKey(
        source: SiteSource.fromStorageValue(value.source),
        gid: value.gid,
      ),
      title: value.title,
      uploader: value.uploader,
      category: value.category,
      thumbnailUrl: Uri.tryParse(value.thumbnailUrl ?? ''),
      sourceUrl: Uri.tryParse(value.sourceUrl ?? ''),
      pageCount: value.pageCount,
      rating: value.rating,
      postedAt: value.postedAt,
      tags: [
        for (final item in decodedTags.whereType<Map<String, dynamic>>())
          GalleryTag(
            namespace: item['namespace'] as String? ?? 'other',
            key: item['key'] as String? ?? '',
            translatedName: item['translatedName'] as String?,
          ),
      ],
    );
  }
}
