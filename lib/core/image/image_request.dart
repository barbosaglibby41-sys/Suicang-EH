enum ImageVariant { thumbnail, cover, reader }

class ImageRequest {
  const ImageRequest({
    required this.url,
    this.referer,
    this.variant = ImageVariant.cover,
    this.targetPixels = 720,
  });

  final Uri url;
  final Uri? referer;
  final ImageVariant variant;
  final int targetPixels;

  String get cacheKey => [
        url.toString(),
        referer?.toString() ?? '',
        variant.name,
        '$targetPixels',
      ].join('|');
}
