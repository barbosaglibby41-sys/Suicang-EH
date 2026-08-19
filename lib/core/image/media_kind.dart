enum MediaKind { image, animatedImage, video }

abstract final class MediaKindResolver {
  static MediaKind fromUri(Uri uri) {
    final extension = uri.pathSegments.isEmpty
        ? ''
        : uri.pathSegments.last.split('.').last.toLowerCase();
    return switch (extension) {
      'gif' || 'webp' => MediaKind.animatedImage,
      'mp4' || 'm4v' || 'mov' || 'webm' => MediaKind.video,
      _ => MediaKind.image,
    };
  }
}
