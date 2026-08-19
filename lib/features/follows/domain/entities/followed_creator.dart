import '../../../gallery/domain/entities/gallery_key.dart';

enum FollowedCreatorKind { artist, uploader }

class FollowedCreator {
  const FollowedCreator({
    required this.id,
    required this.source,
    required this.kind,
    required this.value,
    required this.displayName,
    required this.createdAt,
    this.lastCheckedAt,
    this.lastSeenPublishedAt,
  });

  final String id;
  final SiteSource source;
  final FollowedCreatorKind kind;
  final String value;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastCheckedAt;
  final DateTime? lastSeenPublishedAt;
}
