import 'package:flutter/material.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('下载', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.download_for_offline_outlined,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('下载队列、断点恢复与离线目录将作为独立核心系统实现。'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
