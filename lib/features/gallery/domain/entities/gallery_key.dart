enum SiteSource {
  eHentai('e-hentai', 'E-Hentai'),
  exHentai('exhentai', 'ExHentai');

  const SiteSource(this.storageValue, this.displayName);

  final String storageValue;
  final String displayName;

  static SiteSource fromStorageValue(String value) {
    return SiteSource.values.firstWhere(
      (source) => source.storageValue == value,
      orElse: () => SiteSource.eHentai,
    );
  }
}

class GalleryKey {
  const GalleryKey({required this.source, required this.gid})
      : assert(gid > 0, 'gid must be positive');

  final SiteSource source;
  final int gid;

  String get stableId => '${source.storageValue}:$gid';

  @override
  bool operator ==(Object other) =>
      other is GalleryKey && other.source == source && other.gid == gid;

  @override
  int get hashCode => Object.hash(source, gid);

  @override
  String toString() => stableId;
}
