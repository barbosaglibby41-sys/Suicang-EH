import '../entities/theme_preference.dart';

abstract interface class ThemePreferencesRepository {
  Future<ThemePreference> load();
  Future<void> save(ThemePreference preference);
}
