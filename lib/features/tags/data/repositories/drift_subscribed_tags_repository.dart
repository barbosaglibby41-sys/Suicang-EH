import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/repositories/subscribed_tags_repository.dart';

class DriftSubscribedTagsRepository implements SubscribedTagsRepository {
  DriftSubscribedTagsRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<String>> watchAll() {
    return (_database.select(_database.subscribedTags)
          ..orderBy([(table) => OrderingTerm.asc(table.rawName)]))
        .watch()
        .map((rows) => rows.map((row) => row.rawName).toList(growable: false));
  }

  @override
  Future<bool> contains(String rawName) async {
    final row = await (_database.select(_database.subscribedTags)
          ..where((table) => table.rawName.equals(rawName)))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> toggle(String rawName) async {
    final normalized = rawName.trim();
    if (normalized.isEmpty) return;
    if (await contains(normalized)) {
      await (_database.delete(_database.subscribedTags)
            ..where((table) => table.rawName.equals(normalized)))
          .go();
    } else {
      await _database.into(_database.subscribedTags).insert(
            SubscribedTagsCompanion.insert(
              rawName: normalized,
              createdAt: DateTime.now().toUtc(),
            ),
          );
    }
  }

  @override
  Future<void> clear() => _database.delete(_database.subscribedTags).go();
}
