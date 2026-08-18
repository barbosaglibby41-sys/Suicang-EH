import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/core/database/app_database.dart';
import 'package:taro_eh_flutter/core/migration/migration_importer.dart';

void main() {
  late AppDatabase database;
  late MigrationImporter importer;

  setUp(() {
    database = openTestDatabase(NativeDatabase.memory());
    importer = MigrationImporter(database);
  });

  tearDown(() => database.close());

  test('imports non-sensitive library data once and journals checksum', () async {
    final bundle = jsonEncode({
      'id': 'legacy-v1-device-export',
      'sourceVersion': 1,
      'galleries': [
        {
          'key': 'e-hentai:42',
          'title': 'Migrated Gallery',
          'pageCount': 8,
          'tagsJson': '[]',
        },
      ],
      'favorites': ['e-hentai:42'],
      'history': ['e-hentai:42'],
      'progress': [
        {
          'key': 'e-hentai:42',
          'pageIndex': 3,
          'pageCount': 8,
          'updatedAt': '2026-08-19T00:00:00.000Z',
        },
      ],
    });

    final first = await importer.importJson(bundle);
    final second = await importer.importJson(bundle);

    expect(first.galleries, 1);
    expect(first.favorites, 1);
    expect(first.history, 1);
    expect(first.progress, 1);
    expect(second.alreadyImported, isTrue);
    expect(await database.select(database.galleries).get(), hasLength(1));
    expect(await database.select(database.readingProgressEntries).get(), hasLength(1));
    final journal = await database.select(database.migrationJournal).getSingle();
    expect(journal.status, 'completed');
  });
}
