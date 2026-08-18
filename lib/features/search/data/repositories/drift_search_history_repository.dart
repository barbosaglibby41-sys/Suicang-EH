import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide SearchHistoryEntry;
import '../../domain/entities/search_history_entry.dart';
import '../../domain/repositories/search_history_repository.dart';

class DriftSearchHistoryRepository implements SearchHistoryRepository {
  DriftSearchHistoryRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<SearchHistoryEntry>> watchRecent({int limit = 12}) {
    return (_database.select(_database.searchHistoryEntries)
          ..orderBy([(table) => OrderingTerm.desc(table.usedAt)])
          ..limit(limit))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => SearchHistoryEntry(
                  id: row.id,
                  query: row.query,
                  usedAt: row.usedAt,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<void> record(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    await _database.transaction(() async {
      await (_database.delete(_database.searchHistoryEntries)
            ..where((table) => table.query.equals(normalized)))
          .go();
      await _database.into(_database.searchHistoryEntries).insert(
            SearchHistoryEntriesCompanion.insert(
              query: normalized,
              usedAt: DateTime.now().toUtc(),
            ),
          );
    });
  }

  @override
  Future<void> remove(int id) {
    return (_database.delete(_database.searchHistoryEntries)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<void> clear() => _database.delete(_database.searchHistoryEntries).go();
}
