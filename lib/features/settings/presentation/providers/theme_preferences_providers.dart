import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/shared_preferences_theme_repository.dart';
import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/theme_preferences_repository.dart';

final themePreferencesRepositoryProvider =
    Provider<ThemePreferencesRepository>((ref) {
  return SharedPreferencesThemeRepository();
});

final themePreferenceProvider =
    AsyncNotifierProvider<ThemePreferenceNotifier, ThemePreference>(
  ThemePreferenceNotifier.new,
);

class ThemePreferenceNotifier extends AsyncNotifier<ThemePreference> {
  ThemePreferencesRepository get _repository =>
      ref.read(themePreferencesRepositoryProvider);

  @override
  Future<ThemePreference> build() => _repository.load();

  Future<void> setTheme(ThemePreference preference) async {
    state = AsyncData(preference);
    await _repository.save(preference);
  }
}

ThemeMode toThemeMode(ThemePreference preference) => switch (preference) {
      ThemePreference.system => ThemeMode.system,
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
    };
