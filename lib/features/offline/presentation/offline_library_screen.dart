import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reader/data/page_sources/offline_page_source.dart';
import '../../reader/presentation/reader_screen.dart';
import '../domain/entities/offline_gallery.dart';
import 'providers/offline_library_providers.dart';

class OfflineLibraryScreen extends ConsumerWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(offlineLibraryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('离线书库')),
      body: library.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _OfflineMessage(
          icon: Icons.error_outline,
          message: '离线书库暂时无法读取。',
        ),
        data: (items) => items.isEmpty
            ? const _OfflineMessage(
                icon: Icons.download_done_outlined,
                message: '完成下载的作品会显示在这里。',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _OfflineTile(item: items[index]),
              ),
      ),
    );
  }
}

class _OfflineTile extends ConsumerWidget {
  const _OfflineTile({required this.item});

  final OfflineGallery item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.offline_pin_outlined),
        title: Text(item.gallery.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${item.pagePaths.length} 页 · ${_formatBytes(item.totalBytes)}'),
        onTap: item.isReadable
            ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReaderScreen(
                      gallery: item.gallery,
                      pageSource: OfflinePageSource(
                        item.pagePaths.map(File.new).toList(growable: false),
                      ),
                    ),
                  ),
                )
            : null,
        trailing: IconButton(
          tooltip: '删除离线副本',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => ref.read(offlineLibraryRepositoryProvider).delete(item),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _OfflineMessage extends StatelessWidget {
  const _OfflineMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
