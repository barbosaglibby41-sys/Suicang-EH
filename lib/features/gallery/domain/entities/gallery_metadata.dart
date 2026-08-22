class GalleryMetadata {
  const GalleryMetadata({
    this.language,
    this.fileSize,
    this.favoriteCount,
    this.ratingCount,
    this.torrentUrl,
    this.ratingUser,
    this.ratingAverage,
    this.hasRated = false,
    this.ratingToken,
    this.apiUserId,
    this.apiKey,
  });

  final String? language;
  final String? fileSize;
  final int? favoriteCount;
  final int? ratingCount;
  final Uri? torrentUrl;
  final double? ratingUser;
  final double? ratingAverage;
  final bool hasRated;
  final String? ratingToken;
  final int? apiUserId;
  final String? apiKey;
}
