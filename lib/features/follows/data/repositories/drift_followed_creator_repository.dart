import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/domain/entities/gallery_search_query.dart';
import '../../../gallery/domain/repositories/gallery_repository.dart';
import '../../domain/entities/followed_creator.dart';
import '../../domain/repositories/followed_creator_repository.dart';

class DriftFollowedCreatorRepository implements FollowedCreatorRepository {
  DriftFollowedCreatorRepository({
    required AppDatabase database,
    required GalleryRepository galleryRepository,
  })  : _database = database,
        _galleryRepository = galleryRepository;

  final AppDatabase _database;
  final GalleryRepository _galleryRepository;

  @override
  Stream<List<FollowedCreator>> watchAll() {
    return (_database.select(_database.followedCreators)
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList(growable: false));
  }

  @override
  Future<void> follow(FollowedCreator creator) {
    return _database.into(_database.followedCreators).insertOnConflictUpdate(
          FollowedCreatorsCompanion.insert(
            id: creator.id,
            source: creator.source.storageValue,
            kind: creator.kind.name,
            value: creator.value,
            displayName: creator.displayName,
            createdAt: creator.createdAt,
            lastCheckedAt: Value(creator.lastCheckedAt),
            lastSeenPublishedAt: Value(creator.lastSeenPublishedAt),
          ),
        );
  }

  @override
  Future<void> unfollow(String id) {
    return (_database.delete(_database.followedCreators)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<bool> isFollowing(String id) async {
    final row = await (_database.select(_database.followedCreators)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<List<Gallery>> refresh(FollowedCreator creator) async {
    final query = creator.kind == FollowedCreatorKind.artist
        ? 'artist:"${creator.value}$"'
        : creator.value;
    final page = await _galleryRepository.search(
      GallerySearchQuery(source: creator.source, keyword: query),
    );
    final sorted = [...page.galleries]
      ..sort((left, right) =>
          (right.postedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(left.postedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    final newest = sorted.isEmpty ? null : sorted.first.postedAt;
    await (_database.update(_database.followedCreators)
          ..where((table) => table.id.equals(creator.id)))
        .write(
      FollowedCreatorsCompanion(
        lastCheckedAt: Value(DateTime.now().toUtc()),
        lastSeenPublishedAt: Value(newest),
      ),
    );
    return sorted;
  }

  FollowedCreator _fromRow(FollowedCreator row) => FollowedCreator(
        id: row.id,
        source: SiteSource.fromStorageValue(row.source),
        kind: FollowedCreatorKind.values.byName(row.kind),
        value: row.value,
        displayName: row.displayName,
        createdAt: row.createdAt,
        lastCheckedAt: row.lastCheckedAt,
        lastSeenPublishedAt: row.lastSeenPublishedAt,
      );
}
