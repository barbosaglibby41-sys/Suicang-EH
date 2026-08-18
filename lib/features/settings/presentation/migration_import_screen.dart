import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/migration/migration_importer.dart';
import '../../../core/migration/migration_providers.dart';

class MigrationImportScreen extends ConsumerStatefulWidget {
  const MigrationImportScreen({super.key});

  @override
  ConsumerState<MigrationImportScreen> createState() => _MigrationImportScreenState();
}

class _MigrationImportScreenState extends ConsumerState<MigrationImportScreen> {
  static const _maximumBundleBytes = 10 * 1024 * 1024;
  MigrationImportResult? _result;
  String? _message;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导入旧版数据')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('可导入内容', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('作品元数据、本地收藏、阅读历史和阅读进度。'),
            ),
          ),
          const SizedBox(height: 16),
          Text('不会导入', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('Cookie、Keychain、网页登录会话、密码、Token、API Key 和离线文件路径。登录需要在 Flutter 版本中重新登录或导入 Cookie。'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isImporting ? null : _pickAndImport,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(_isImporting ? '正在导入…' : '选择迁移 JSON 文件'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 20),
            Text(_message!),
          ],
          if (_result != null && !_result!.alreadyImported) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('导入完成'),
                    const SizedBox(height: 8),
                    Text('作品：${_result!.galleries}'),
                    Text('收藏：${_result!.favorites}'),
                    Text('历史：${_result!.history}'),
                    Text('进度：${_result!.progress}'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            '导入不会修改旧版 Swift App 数据。确认新版本中的书架、历史和进度无误后，再决定是否移除旧 App。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndImport() async {
    setState(() {
      _isImporting = true;
      _message = null;
      _result = null;
    });
    try {
      final selected = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      final files = selected?.files ?? const <PlatformFile>[];
      final bytes = files.isEmpty ? null : files.first.bytes;
      if (bytes == null) {
        _message = '未选择迁移文件。';
      } else if (bytes.length > _maximumBundleBytes) {
        _message = '迁移文件超过 10 MB 限制，未导入。';
      } else {
        final raw = utf8.decode(bytes, allowMalformed: false);
        final result = await ref.read(migrationImporterProvider).importJson(raw);
        _result = result;
        _message = result.alreadyImported ? '该迁移包此前已完成导入，无需重复写入。' : '迁移包已安全导入。';
      }
    } on FormatException {
      _message = '迁移文件不是有效 UTF-8 JSON，未导入。';
    } catch (_) {
      _message = '无法导入迁移文件。请检查格式后重试。';
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}
