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

  /// Network bytes remain cacheable, while decode callers use this target to
  /// cap raster memory for covers and reader pages.
  int get decodeTargetPixels => targetPixels.clamp(1, 4096);

  String get cacheKey => [
        url.toString(),
        referer?.toString() ?? '',
        variant.name,
        '$targetPixels',
      ].join('|');
}
