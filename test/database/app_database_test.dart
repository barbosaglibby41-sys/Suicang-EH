import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = openTestDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('enforces one gallery row per source and gid', () async {
    final now = DateTime.utc(2026, 8, 19);
    await database.into(database.galleries).insert(
          GalleriesCompanion.insert(
            source: 'e-hentai',
            gid: 42,
            title: 'First title',
            updatedAt: now,
          ),
        );

    await database.into(database.galleries).insertOnConflictUpdate(
          GalleriesCompanion.insert(
            source: 'e-hentai',
            gid: 42,
            title: 'Updated title',
            updatedAt: now.add(const Duration(seconds: 1)),
          ),
        );

    final rows = await database.select(database.galleries).get();
    expect(rows, hasLength(1));
    expect(rows.single.title, 'Updated title');
  });

  test('keeps identical gids separate across site sources', () async {
    final now = DateTime.utc(2026, 8, 19);
    for (final source in ['e-hentai', 'exhentai']) {
      await database.into(database.galleries).insert(
            GalleriesCompanion.insert(
              source: source,
              gid: 7,
              title: source,
              updatedAt: now,
            ),
          );
    }

    final rows = await database.select(database.galleries).get();
    expect(rows, hasLength(2));
  });
}
