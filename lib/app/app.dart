import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/taro_theme.dart';

class SuicangEhApp extends ConsumerWidget {
  const SuicangEhApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Suicang EH',
      debugShowCheckedModeBanner: false,
      theme: TaroTheme.light(),
      darkTheme: TaroTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
