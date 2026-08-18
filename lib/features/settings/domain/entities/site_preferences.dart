import '../../../gallery/domain/entities/gallery_key.dart';

class SitePreferences {
  const SitePreferences({
    this.source = SiteSource.eHentai,
  });

  final SiteSource source;

  SitePreferences copyWith({SiteSource? source}) =>
      SitePreferences(source: source ?? this.source);
}
