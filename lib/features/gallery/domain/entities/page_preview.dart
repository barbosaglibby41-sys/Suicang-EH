class PagePreview {
  const PagePreview({
    required this.page,
    required this.spriteUrl,
    required this.xOffset,
    required this.yOffset,
    required this.width,
    required this.height,
    required this.pageUrl,
    required this.referer,
  });

  final int page;
  final Uri spriteUrl;
  final int xOffset;
  final int yOffset;
  final int width;
  final int height;
  final Uri pageUrl;

  /// The gallery detail URL. Sprite hosts validate the document referrer.
  final Uri referer;
}
