import '../../../gallery/domain/entities/gallery_key.dart';

class SitePreferences {
  const SitePreferences({
    this.source = SiteSource.eHentai,
    this.preferPublicDetailRedirect = true,
  });

  final SiteSource source;
  final bool preferPublicDetailRedirect;

  SitePreferences copyWith({
    SiteSource? source,
    bool? preferPublicDetailRedirect,
  }) =>
      SitePreferences(
        source: source ?? this.source,
        preferPublicDetailRedirect:
            preferPublicDetailRedirect ?? this.preferPublicDetailRedirect,
      );
}
