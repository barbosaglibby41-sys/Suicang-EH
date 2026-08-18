import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../errors/app_exception.dart';
import 'migration_bundle.dart';

class MigrationImporter {
  MigrationImporter(this._database);

  final AppDatabase _database;

  Future<MigrationImportResult> importJson(String raw) async {
    final checksum = sha256.convert(utf8.encode(raw)).toString();
    final bundle = MigrationBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    if (bundle.id.trim().isEmpty) {
      throw const MigrationException('Migration bundle ID is required.');
    }
    final existing = await (_database.select(_database.migrationJournal)
          ..where((table) => table.id.equals(bundle.id)))
        .getSingleOrNull();
    if (existing?.status == 'completed' && existing?.checksum == checksum) {
      return const MigrationImportResult(alreadyImported: true);
    }

    var galleries = 0;
    var favorites = 0;
    var history = 0;
    var progress = 0;
    await _database.transaction(() async {
      await _database.into(_database.migrationJournal).insertOnConflictUpdate(
            MigrationJournalCompanion.insert(
              id: bundle.id,
              sourceVersion: bundle.sourceVersion,
              status: 'running',
              checksum: Value(checksum),
              importedAt: const Value(null),
            ),
          );
      final known = <String, MigrationGallery>{
        for (final gallery in bundle.galleries) gallery.key: gallery,
      };
      for (final gallery in known.values) {
        final key = _parseKey(gallery.key);
        if (key == null) continue;
        await _database.into(_database.galleries).insertOnConflictUpdate(
              GalleriesCompanion.insert(
                source: key.$1,
                gid: key.$2,
                title: gallery.title,
                uploader: Value(gallery.uploader),
                category: Value(gallery.category),
                thumbnailUrl: Value(gallery.thumbnailUrl),
                sourceUrl: Value(gallery.sourceUrl),
                pageCount: Value(gallery.pageCount),
                tagsJson: Value(gallery.tagsJson),
                updatedAt: DateTime.now().toUtc(),
              ),
            );
        galleries += 1;
      }
      for (final rawKey in bundle.favorites) {
        final key = _parseKey(rawKey);
        if (key == null || !known.containsKey(rawKey)) continue;
        await _database.into(_database.libraryEntries).insertOnConflictUpdate(
              LibraryEntriesCompanion.insert(
                source: key.$1,
                gid: key.$2,
                isFavorite: const Value(true),
                lastOpenedAt: const Value.absent(),
              ),
            );
        favorites += 1;
      }
      for (final rawKey in bundle.history) {
        final key = _parseKey(rawKey);
        if (key == null || !known.containsKey(rawKey)) continue;
        await _database.into(_database.libraryEntries).insertOnConflictUpdate(
              LibraryEntriesCompanion.insert(
                source: key.$1,
                gid: key.$2,
                isFavorite: const Value.absent(),
                lastOpenedAt: Value(DateTime.now().toUtc()),
              ),
            );
        history += 1;
      }
      for (final item in bundle.progress) {
        final key = _parseKey(item.key);
        if (key == null) continue;
        await _database.into(_database.readingProgressEntries).insertOnConflictUpdate(
              ReadingProgressEntriesCompanion.insert(
                source: key.$1,
                gid: key.$2,
                pageIndex: item.pageIndex,
                pageCount: item.pageCount,
                updatedAt: item.updatedAt,
              ),
            );
        progress += 1;
      }
      await _database.into(_database.migrationJournal).insertOnConflictUpdate(
            MigrationJournalCompanion.insert(
              id: bundle.id,
              sourceVersion: bundle.sourceVersion,
              status: 'completed',
              checksum: Value(checksum),
              importedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    return MigrationImportResult(
      galleries: galleries,
      favorites: favorites,
      history: history,
      progress: progress,
    );
  }

  (String, int)? _parseKey(String raw) {
    final separator = raw.lastIndexOf(':');
    if (separator <= 0 || separator == raw.length - 1) return null;
    final gid = int.tryParse(raw.substring(separator + 1));
    if (gid == null || gid <= 0) return null;
    return (raw.substring(0, separator), gid);
  }
}

class MigrationImportResult {
  const MigrationImportResult({
    this.alreadyImported = false,
    this.galleries = 0,
    this.favorites = 0,
    this.history = 0,
    this.progress = 0,
  });

  final bool alreadyImported;
  final int galleries;
  final int favorites;
  final int history;
  final int progress;
}
