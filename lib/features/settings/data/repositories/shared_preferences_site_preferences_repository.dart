import 'package:shared_preferences/shared_preferences.dart';

import '../../../gallery/domain/entities/gallery_key.dart';
import '../../domain/entities/site_preferences.dart';
import '../../domain/repositories/site_preferences_repository.dart';

class SharedPreferencesSitePreferencesRepository
    implements SitePreferencesRepository {
  static const _sourceKey = 'taro.eh.site.source';
  static const _preferPublicDetailRedirectKey =
      'taro.eh.site.prefer_public_detail_redirect';

  @override
  Future<SitePreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    return SitePreferences(
      source: SiteSource.fromStorageValue(
        preferences.getString(_sourceKey) ?? SiteSource.eHentai.storageValue,
      ),
      preferPublicDetailRedirect:
          preferences.getBool(_preferPublicDetailRedirectKey) ?? true,
    );
  }

  @override
  Future<void> save(SitePreferences preferences) async {
    final storage = await SharedPreferences.getInstance();
    await Future.wait([
      storage.setString(_sourceKey, preferences.source.storageValue),
      storage.setBool(
        _preferPublicDetailRedirectKey,
        preferences.preferPublicDetailRedirect,
      ),
    ]);
  }
}
