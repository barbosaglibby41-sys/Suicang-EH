class MigrationBundle {
  const MigrationBundle({
    required this.id,
    required this.sourceVersion,
    required this.galleries,
    required this.favorites,
    required this.history,
    required this.progress,
  });

  final String id;
  final int sourceVersion;
  final List<MigrationGallery> galleries;
  final List<String> favorites;
  final List<String> history;
  final List<MigrationProgress> progress;

  factory MigrationBundle.fromJson(Map<String, dynamic> json) {
    return MigrationBundle(
      id: json['id'] as String,
      sourceVersion: json['sourceVersion'] as int,
      galleries: [
        for (final value in (json['galleries'] as List<dynamic>? ?? const []))
          MigrationGallery.fromJson(value as Map<String, dynamic>),
      ],
      favorites:
          (json['favorites'] as List<dynamic>? ?? const []).cast<String>(),
      history: (json['history'] as List<dynamic>? ?? const []).cast<String>(),
      progress: [
        for (final value in (json['progress'] as List<dynamic>? ?? const []))
          MigrationProgress.fromJson(value as Map<String, dynamic>),
      ],
    );
  }
}

class MigrationGallery {
  const MigrationGallery({
    required this.key,
    required this.title,
    required this.pageCount,
    this.uploader = '',
    this.category = '',
    this.thumbnailUrl,
    this.sourceUrl,
    this.tagsJson = '[]',
  });

  final String key;
  final String title;
  final int pageCount;
  final String uploader;
  final String category;
  final String? thumbnailUrl;
  final String? sourceUrl;
  final String tagsJson;

  factory MigrationGallery.fromJson(Map<String, dynamic> json) =>
      MigrationGallery(
        key: json['key'] as String,
        title: json['title'] as String? ?? '',
        pageCount: json['pageCount'] as int? ?? 0,
        uploader: json['uploader'] as String? ?? '',
        category: json['category'] as String? ?? '',
        thumbnailUrl: json['thumbnailUrl'] as String?,
        sourceUrl: json['sourceUrl'] as String?,
        tagsJson: json['tagsJson'] as String? ?? '[]',
      );
}

class MigrationProgress {
  const MigrationProgress({
    required this.key,
    required this.pageIndex,
    required this.pageCount,
    required this.updatedAt,
  });

  final String key;
  final int pageIndex;
  final int pageCount;
  final DateTime updatedAt;

  factory MigrationProgress.fromJson(Map<String, dynamic> json) =>
      MigrationProgress(
        key: json['key'] as String,
        pageIndex: json['pageIndex'] as int? ?? 0,
        pageCount: json['pageCount'] as int? ?? 0,
        updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      );
}
