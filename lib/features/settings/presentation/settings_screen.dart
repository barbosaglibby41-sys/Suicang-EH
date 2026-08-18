import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gallery/domain/entities/gallery_key.dart';
import '../../reader/presentation/reader_settings_screen.dart';
import '../domain/entities/site_preferences.dart';
import 'migration_import_screen.dart';
import 'providers/site_preferences_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sitePreferences = ref.watch(sitePreferencesProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('设置', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        Text('站点来源', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        sitePreferences.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('无法读取站点来源设置。'),
          data: (preferences) => Card(
            child: Column(
              children: [
                RadioListTile<SiteSource>(
                  value: SiteSource.eHentai,
                  groupValue: preferences.source,
                  title: const Text('E-Hentai'),
                  onChanged: (source) {
                    if (source != null) {
                      ref.read(sitePreferencesProvider.notifier).setPreferences(
                            preferences.copyWith(source: source),
                          );
                    }
                  },
                ),
                RadioListTile<SiteSource>(
                  value: SiteSource.exHentai,
                  groupValue: preferences.source,
                  title: const Text('ExHentai'),
                  subtitle: const Text('需要有效登录会话。'),
                  onChanged: (source) {
                    if (source != null) {
                      ref.read(sitePreferencesProvider.notifier).setPreferences(
                            preferences.copyWith(source: source),
                          );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading:
                Icon(Icons.person_outline, color: theme.colorScheme.primary),
            title: const Text('账户与会话'),
            subtitle: const Text('导入 Cookie、验证站点会话与刷新 ExHentai。'),
            onTap: () => context.push('/account'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.move_to_inbox_outlined,
                color: theme.colorScheme.primary),
            title: const Text('导入旧版数据'),
            subtitle: const Text('导入收藏、历史和阅读进度，不导入账号会话。'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const MigrationImportScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.menu_book_outlined,
                color: theme.colorScheme.primary),
            title: const Text('阅读设置'),
            subtitle: const Text('阅读方式、方向、页面适配和屏幕常亮。'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const ReaderSettingsScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
            title: const Text('本机安全存储'),
            subtitle: const Text('Cookie 将只通过 Keychain / Android Keystore 保存。'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading:
                Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
            title: const Text('外观'),
            subtitle: const Text('亮色、暗色与自适应布局已建立基础主题。'),
          ),
        ),
      ],
    );
  }
}
