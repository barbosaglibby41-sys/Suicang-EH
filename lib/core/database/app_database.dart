import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('GalleryRow')
class Galleries extends Table {
  TextColumn get source => text()();
  IntColumn get gid => integer()();
  TextColumn get title => text()();
  TextColumn get uploader => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  IntColumn get pageCount => integer().withDefault(const Constant(0))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  RealColumn get rating => real().nullable()();
  DateTimeColumn get postedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {source, gid};
}

class LibraryEntries extends Table {
  TextColumn get source => text()();
  IntColumn get gid => integer()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get favoritedAt => dateTime().nullable()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {source, gid};
}

class ReadingProgressEntries extends Table {
  TextColumn get source => text()();
  IntColumn get gid => integer()();
  IntColumn get pageIndex => integer()();
  IntColumn get pageCount => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {source, gid};
}

class DownloadTasks extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  IntColumn get gid => integer()();
  TextColumn get status => text()();
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  IntColumn get completedPages => integer().withDefault(const Constant(0))();
  TextColumn get targetDirectory => text().nullable()();
  TextColumn get failureCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DownloadPages extends Table {
  TextColumn get taskId => text()();
  IntColumn get pageIndex => integer()();
  TextColumn get pageUrl => text().nullable()();
  TextColumn get localPath => text().nullable()();
  IntColumn get byteCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get checksum => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {taskId, pageIndex};
}

class ImageUrlCacheEntries extends Table {
  TextColumn get source => text()();
  IntColumn get gid => integer()();
  IntColumn get pageIndex => integer()();
  TextColumn get pageUrl => text().nullable()();
  TextColumn get resolvedImageUrl => text().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {source, gid, pageIndex};
}

class SearchHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  DateTimeColumn get usedAt => dateTime()();
}

class SubscribedTags extends Table {
  TextColumn get rawName => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {rawName};
}

class TagDatabaseMetadata extends Table {
  IntColumn get id => integer()();
  IntColumn get version => integer()();
  TextColumn get source => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MigrationJournal extends Table {
  TextColumn get id => text()();
  IntColumn get sourceVersion => integer()();
  TextColumn get status => text()();
  TextColumn get checksum => text().nullable()();
  DateTimeColumn get importedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Galleries,
    LibraryEntries,
    ReadingProgressEntries,
    DownloadTasks,
    DownloadPages,
    ImageUrlCacheEntries,
    SearchHistoryEntries,
    SubscribedTags,
    TagDatabaseMetadata,
    MigrationJournal,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() => AppDatabase(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(libraryEntries, libraryEntries.favoritedAt);
            await customStatement(
              'UPDATE library_entries SET favorited_at = last_opened_at '
              'WHERE is_favorite = 1 AND favorited_at IS NULL',
            );
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(path.join(directory.path, 'taro_eh.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@visibleForTesting
AppDatabase openTestDatabase(QueryExecutor executor) => AppDatabase(executor);
