class GalleryMetadata {
  const GalleryMetadata({
    this.language,
    this.fileSize,
    this.favoriteCount,
    this.ratingCount,
    this.torrentUrl,
  });

  final String? language;
  final String? fileSize;
  final int? favoriteCount;
  final int? ratingCount;
  final Uri? torrentUrl;
}
