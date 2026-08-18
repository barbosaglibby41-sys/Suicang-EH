import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/domain/entities/gallery_tag.dart';
import '../../domain/entities/offline_gallery.dart';
import '../../domain/repositories/offline_library_repository.dart';

class DriftOfflineLibraryRepository implements OfflineLibraryRepository {
  DriftOfflineLibraryRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<OfflineGallery>> watchCompleted() {
    final query = _database.select(_database.downloadTasks).join([
      innerJoin(
        _database.galleries,
        _database.galleries.source.equalsExp(_database.downloadTasks.source) &
            _database.galleries.gid.equalsExp(_database.downloadTasks.gid),
      ),
      leftOuterJoin(
        _database.downloadPages,
        _database.downloadPages.taskId.equalsExp(_database.downloadTasks.id),
      ),
    ])
      ..where(_database.downloadTasks.status.equals('completed'))
      ..orderBy([OrderingTerm.desc(_database.downloadTasks.updatedAt)]);
    return query.watch().map(_groupRows);
  }

  @override
  Future<void> delete(OfflineGallery gallery) async {
    await _database.transaction(() async {
      await (_database.delete(_database.downloadPages)
            ..where((table) => table.taskId.equals(gallery.taskId)))
          .go();
      await (_database.delete(_database.downloadTasks)
            ..where((table) => table.id.equals(gallery.taskId)))
          .go();
    });
    for (final path in gallery.pagePaths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // DB removal is retained; the next reconcile can clean an orphan.
      }
    }
  }

  List<OfflineGallery> _groupRows(List<TypedResult> rows) {
    final grouped = <String, _OfflineAccumulator>{};
    for (final row in rows) {
      final task = row.readTable(_database.downloadTasks);
      final gallery = row.readTable(_database.galleries);
      final page = row.readTableOrNull(_database.downloadPages);
      final value = grouped.putIfAbsent(
        task.id,
        () => _OfflineAccumulator(task.id, _galleryFromRow(gallery)),
      );
      if (page?.localPath case final localPath?) {
        value.pagePaths.add(localPath);
        value.totalBytes += page!.byteCount;
      }
    }
    return grouped.values
        .map(
          (value) => OfflineGallery(
            gallery: value.gallery,
            taskId: value.taskId,
            pagePaths: value.pagePaths..sort(),
            totalBytes: value.totalBytes,
          ),
        )
        .toList(growable: false);
  }

  Gallery _galleryFromRow(GalleryRow row) => Gallery(
        key: GalleryKey(
          source: SiteSource.fromStorageValue(row.source),
          gid: row.gid,
        ),
        title: row.title,
        uploader: row.uploader,
        category: row.category,
        thumbnailUrl: Uri.tryParse(row.thumbnailUrl ?? ''),
        sourceUrl: Uri.tryParse(row.sourceUrl ?? ''),
        pageCount: row.pageCount,
        rating: row.rating,
        postedAt: row.postedAt,
        tags: _decodeTags(row.tagsJson),
      );

  List<GalleryTag> _decodeTags(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return [
      for (final entry in decoded.whereType<Map<String, dynamic>>())
        GalleryTag(
          namespace: entry['namespace'] as String? ?? 'other',
          key: entry['key'] as String? ?? '',
          translatedName: entry['translatedName'] as String?,
        ),
    ];
  }
}

class _OfflineAccumulator {
  _OfflineAccumulator(this.taskId, this.gallery);

  final String taskId;
  final Gallery gallery;
  final pagePaths = <String>[];
  var totalBytes = 0;
}
