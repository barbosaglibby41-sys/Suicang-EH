import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/theme_preferences_repository.dart';

class SharedPreferencesThemeRepository implements ThemePreferencesRepository {
  static const _key = 'suicang.eh.theme.preference';

  @override
  Future<ThemePreference> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    for (final value in ThemePreference.values) {
      if (value.storageValue == raw) return value;
    }
    return ThemePreference.dark;
  }

  @override
  Future<void> save(ThemePreference preference) async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString(_key, preference.storageValue);
  }
}
