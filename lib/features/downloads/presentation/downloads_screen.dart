import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/download_task.dart';
import 'providers/download_providers.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadTasksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('下载队列')),
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('下载队列暂时不可用。')),
        data: (items) => items.isEmpty
            ? const _DownloadEmpty()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _DownloadTaskTile(task: items[index]),
              ),
      ),
    );
  }
}

class _DownloadTaskTile extends ConsumerWidget {
  const _DownloadTaskTile({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(downloadRepositoryProvider);
    final isWorking = task.status == DownloadStatus.downloading ||
        task.status == DownloadStatus.queued;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.download_for_offline_outlined),
                const SizedBox(width: 10),
                Expanded(child: Text(task.galleryKey.stableId)),
                _StatusLabel(status: task.status),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: task.progress),
            const SizedBox(height: 8),
            Text('${task.completedPages} / ${task.totalPages} 页'),
            if (task.failureCode != null) ...[
              const SizedBox(height: 4),
              Text('下载失败，可重试。',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isWorking)
                  IconButton(
                    tooltip: '暂停',
                    onPressed: () => repository.pause(task.id),
                    icon: const Icon(Icons.pause_outlined),
                  )
                else if (task.status == DownloadStatus.paused ||
                    task.status == DownloadStatus.queued)
                  IconButton(
                    tooltip: '继续',
                    onPressed: () => repository.resume(task.id),
                    icon: const Icon(Icons.play_arrow_outlined),
                  )
                else if (task.status == DownloadStatus.failed)
                  IconButton(
                    tooltip: '重试',
                    onPressed: () => repository.retry(task.id),
                    icon: const Icon(Icons.refresh),
                  ),
                IconButton(
                  tooltip: '取消并删除文件',
                  onPressed: () =>
                      repository.cancel(task.id, deleteFiles: true),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final DownloadStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      DownloadStatus.queued => '等待中',
      DownloadStatus.downloading => '下载中',
      DownloadStatus.paused => '已暂停',
      DownloadStatus.completed => '已完成',
      DownloadStatus.failed => '失败',
      DownloadStatus.cancelled => '已取消',
    };
    return Text(label, style: Theme.of(context).textTheme.labelSmall);
  }
}

class _DownloadEmpty extends StatelessWidget {
  const _DownloadEmpty();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download_done_outlined, size: 44),
              const SizedBox(height: 14),
              Text('暂无下载任务', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              const Text('从作品详情页将作品加入离线下载队列。'),
            ],
          ),
        ),
      );
}
