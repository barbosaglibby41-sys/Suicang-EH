import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/reader_models.dart';
import 'providers/reader_preferences_providers.dart';

class ReaderSettingsScreen extends ConsumerWidget {
  const ReaderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(readerPreferencesProvider);
    final notifier = ref.read(readerPreferencesProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('阅读设置')),
      body: preferences.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('阅读设置暂时无法读取。')),
        data: (value) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('默认阅读方式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<ReaderMode>(
                    value: ReaderMode.horizontal,
                    groupValue: value.mode,
                    title: const Text('横向分页'),
                    subtitle: const Text('逐页滑动，适合传统漫画阅读。'),
                    onChanged: (mode) {
                      if (mode != null) notifier.update(value.copyWith(mode: mode));
                    },
                  ),
                  RadioListTile<ReaderMode>(
                    value: ReaderMode.vertical,
                    groupValue: value.mode,
                    title: const Text('纵向长条'),
                    subtitle: const Text('连续滚动，适合长图。'),
                    onChanged: (mode) {
                      if (mode != null) notifier.update(value.copyWith(mode: mode));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('阅读方向', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<ReaderDirection>(
                    value: ReaderDirection.ltr,
                    groupValue: value.direction,
                    title: const Text('从左到右'),
                    onChanged: (direction) {
                      if (direction != null) {
                        notifier.update(value.copyWith(direction: direction));
                      }
                    },
                  ),
                  RadioListTile<ReaderDirection>(
                    value: ReaderDirection.rtl,
                    groupValue: value.direction,
                    title: const Text('从右到左'),
                    onChanged: (direction) {
                      if (direction != null) {
                        notifier.update(value.copyWith(direction: direction));
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('页面适配', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<ReaderFit>(
                    value: ReaderFit.contain,
                    groupValue: value.fit,
                    title: const Text('完整显示'),
                    onChanged: (fit) {
                      if (fit != null) notifier.update(value.copyWith(fit: fit));
                    },
                  ),
                  RadioListTile<ReaderFit>(
                    value: ReaderFit.cover,
                    groupValue: value.fit,
                    title: const Text('填充屏幕'),
                    onChanged: (fit) {
                      if (fit != null) notifier.update(value.copyWith(fit: fit));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: SwitchListTile(
                value: value.keepScreenOn,
                title: const Text('阅读时保持屏幕常亮'),
                subtitle: const Text('偏好已保存；系统保持唤醒能力将在原生 adapter 接入后生效。'),
                onChanged: (enabled) =>
                    notifier.update(value.copyWith(keepScreenOn: enabled)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
