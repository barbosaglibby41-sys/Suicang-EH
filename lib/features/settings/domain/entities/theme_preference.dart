enum ThemePreference { system, light, dark }

extension ThemePreferenceX on ThemePreference {
  String get storageValue => name;

  String get displayName => switch (this) {
        ThemePreference.system => '跟随系统',
        ThemePreference.light => '浅色主题',
        ThemePreference.dark => '深色主题',
      };
}
