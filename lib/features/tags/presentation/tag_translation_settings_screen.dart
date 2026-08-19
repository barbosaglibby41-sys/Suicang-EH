import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/tag_translation_providers.dart';

class TagTranslationSettingsScreen extends ConsumerStatefulWidget {
  const TagTranslationSettingsScreen({super.key});

  @override
  ConsumerState<TagTranslationSettingsScreen> createState() =>
      _TagTranslationSettingsScreenState();
}

class _TagTranslationSettingsScreenState
    extends ConsumerState<TagTranslationSettingsScreen> {
  bool _working = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(tagDatabaseStatusProvider);
    final repository = ref.read(tagTranslationRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('标签翻译')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.translate_outlined),
              title: Text('显示标签翻译'),
              subtitle: Text('搜索补全和详情标签优先显示中文名称。'),
            ),
          ),
          const SizedBox(height: 12),
          status.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('标签数据库状态不可用。'),
            data: (value) => ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: Text(value.isBundled ? '内置数据库' : '本地更新数据库'),
              subtitle: Text(
                '版本 ${value.version} · ${value.tagCount} 个标签'
                '${value.updatedAt == null ? '' : ' · ${value.updatedAt!.toLocal().toIso8601String().split('T').first}'}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _working
                ? null
                : () async {
                    setState(() {
                      _working = true;
                      _message = null;
                    });
                    try {
                      final updated = await repository.updateFromRemote();
                      ref.invalidate(tagDatabaseStatusProvider);
                      ref.invalidate(tagTranslationReadyProvider);
                      _message = '已更新到标签数据库版本 ${updated.version}。';
                    } catch (_) {
                      _message = '更新失败，继续使用当前标签数据库。';
                    } finally {
                      if (mounted) setState(() => _working = false);
                    }
                  },
            icon: _working
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_download_outlined),
            label: const Text('更新最新翻译库'),
          ),
          OutlinedButton.icon(
            onPressed: _working
                ? null
                : () async {
                    await repository.restoreBundled();
                    ref.invalidate(tagDatabaseStatusProvider);
                    ref.invalidate(tagTranslationReadyProvider);
                    if (mounted) setState(() => _message = '已恢复内置标签数据库。');
                  },
            icon: const Icon(Icons.restore_outlined),
            label: const Text('恢复内置版本'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!),
          ],
        ],
      ),
    );
  }
}
