import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/domain/entities/gallery_tag.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/entities/library_filter.dart';

class DriftLibraryRepository implements LibraryRepository {
  DriftLibraryRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<Gallery>> watchFavorites({LibraryFilter filter = const LibraryFilter()}) {
    final query = _database.select(_database.galleries).join([
      innerJoin(
        _database.libraryEntries,
        _database.libraryEntries.source.equalsExp(_database.galleries.source) &
            _database.libraryEntries.gid.equalsExp(_database.galleries.gid),
      ),
    ])
      ..where(_database.libraryEntries.isFavorite.equals(true));
    if (filter.date != null) {
      final start = DateTime(filter.date!.year, filter.date!.month, filter.date!.day);
      final end = start.add(const Duration(days: 1));
      query.where(
        filter.sort == LibrarySort.publishedTime
            ? (_database.galleries.postedAt.isBiggerOrEqualValue(start) &
                _database.galleries.postedAt.isSmallerThanValue(end))
            : (_database.libraryEntries.favoritedAt.isBiggerOrEqualValue(start) &
                _database.libraryEntries.favoritedAt.isSmallerThanValue(end)),
      );
    }
    query.orderBy([
      filter.sort == LibrarySort.publishedTime
          ? OrderingTerm.desc(_database.galleries.postedAt)
          : OrderingTerm.desc(_database.libraryEntries.favoritedAt),
    ]);
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
      ..where(_database.libraryEntries.lastOpenedAt.isNotNull());
    if (filter.date != null) {
      final start = DateTime(filter.date!.year, filter.date!.month, filter.date!.day);
      final end = start.add(const Duration(days: 1));
      query.where(
        _database.libraryEntries.lastOpenedAt.isBiggerOrEqualValue(start) &
            _database.libraryEntries.lastOpenedAt.isSmallerThanValue(end),
      );
    }
    query.orderBy([OrderingTerm.desc(_database.libraryEntries.lastOpenedAt)])
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
              favoritedAt: value
                  ? Value(DateTime.now().toUtc())
                  : const Value(null),
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
