import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/taro_theme.dart';
import '../features/settings/domain/entities/theme_preference.dart';
import '../features/settings/presentation/providers/theme_preferences_providers.dart';

class SuicangEhApp extends ConsumerWidget {
  const SuicangEhApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final preference =
        ref.watch(themePreferenceProvider).valueOrNull ?? ThemePreference.dark;

    return MaterialApp.router(
      title: 'Suicang EH',
      debugShowCheckedModeBanner: false,
      theme: TaroTheme.light(),
      darkTheme: TaroTheme.dark(),
      themeMode: toThemeMode(preference),
      routerConfig: router,
    );
  }
}
