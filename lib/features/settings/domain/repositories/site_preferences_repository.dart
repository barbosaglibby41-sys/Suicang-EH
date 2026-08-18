import '../entities/site_preferences.dart';

abstract interface class SitePreferencesRepository {
  Future<SitePreferences> load();
  Future<void> save(SitePreferences preferences);
}
