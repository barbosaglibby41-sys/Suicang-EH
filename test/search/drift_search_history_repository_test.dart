import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/core/database/app_database.dart';
import 'package:taro_eh_flutter/features/search/data/repositories/drift_search_history_repository.dart';

void main() {
  late AppDatabase database;
  late DriftSearchHistoryRepository repository;

  setUp(() {
    database = openTestDatabase(NativeDatabase.memory());
    repository = DriftSearchHistoryRepository(database);
  });

  tearDown(() => database.close());

  test('deduplicates equivalent search records and promotes latest usage', () async {
    await repository.record('artist:sample');
    await repository.record('female:example');
    await repository.record('artist:sample');

    final entries = await repository.watchRecent().first;
    expect(entries.map((entry) => entry.query), ['artist:sample', 'female:example']);
  });

  test('removes a single record and clears all records', () async {
    await repository.record('one');
    await repository.record('two');
    final entries = await repository.watchRecent().first;
    await repository.remove(entries.first.id);
    expect((await repository.watchRecent().first), hasLength(1));
    await repository.clear();
    expect((await repository.watchRecent().first), isEmpty);
  });
}
