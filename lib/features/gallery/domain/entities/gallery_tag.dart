class GalleryTag {
  const GalleryTag({
    required this.namespace,
    required this.key,
    this.translatedName,
  });

  final String namespace;
  final String key;
  final String? translatedName;

  String get rawName => namespace.isEmpty ? key : '$namespace:$key';

  factory GalleryTag.parse(String raw) {
    final normalized = raw.trim();
    final separator = normalized.indexOf(':');
    if (separator <= 0 || separator == normalized.length - 1) {
      return GalleryTag(namespace: 'other', key: normalized);
    }
    return GalleryTag(
      namespace: normalized.substring(0, separator),
      key: normalized.substring(separator + 1),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GalleryTag &&
      other.namespace == namespace &&
      other.key == key &&
      other.translatedName == translatedName;

  @override
  int get hashCode => Object.hash(namespace, key, translatedName);
}
