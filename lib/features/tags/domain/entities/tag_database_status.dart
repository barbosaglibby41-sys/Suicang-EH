class TagDatabaseStatus {
  const TagDatabaseStatus({
    required this.version,
    required this.updatedAt,
    required this.tagCount,
    required this.isBundled,
  });

  final int version;
  final DateTime? updatedAt;
  final int tagCount;
  final bool isBundled;
}
