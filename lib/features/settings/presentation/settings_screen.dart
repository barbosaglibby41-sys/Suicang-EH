import 'package:flutter/material.dart';
import '../../reader/presentation/reader_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('设置', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
            title: const Text('账户与会话'),
            subtitle: const Text('导入 Cookie、验证站点会话与刷新 ExHentai。'),
            onTap: () => context.push('/account'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.menu_book_outlined, color: theme.colorScheme.primary),
            title: const Text('阅读设置'),
            subtitle: const Text('阅读方式、方向、页面适配和屏幕常亮。'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReaderSettingsScreen()),
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
            leading: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
            title: const Text('外观'),
            subtitle: const Text('亮色、暗色与自适应布局已建立基础主题。'),
          ),
        ),
      ],
    );
  }
}
