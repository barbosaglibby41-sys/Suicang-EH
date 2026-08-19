import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/presentation/widgets/gallery_cover.dart';
import '../domain/entities/followed_creator.dart';
import 'providers/followed_creator_providers.dart';

class FollowedCreatorsScreen extends ConsumerStatefulWidget {
  const FollowedCreatorsScreen({
    this.embedded = false,
    super.key,
  });

  final bool embedded;

  @override
  ConsumerState<FollowedCreatorsScreen> createState() =>
      _FollowedCreatorsScreenState();
}

class _FollowedCreatorsScreenState
    extends ConsumerState<FollowedCreatorsScreen> {
  final _results = <String, List<Gallery>>{};
  final _loading = <String>{};
  var _initialRefreshTriggered = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(followedCreatorsProvider, (_, next) {
      final creators = next.valueOrNull;
      if (!_initialRefreshTriggered && creators != null) {
        _initialRefreshTriggered = true;
        _refreshAll(creators);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final followed = ref.watch(followedCreatorsProvider);
    final content = followed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('无法读取关注列表。')),
        data: (creators) => creators.isEmpty
            ? const Center(child: Text('在作品详情页关注作者或发布者后，新作品会出现在这里。'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: creators.length,
                itemBuilder: (context, index) => _CreatorSection(
                  creator: creators[index],
                  galleries: _results[creators[index].id] ?? const [],
                  loading: _loading.contains(creators[index].id),
                  onRefresh: () => _refresh(creators[index]),
                  onUnfollow: () => ref
                      .read(followedCreatorRepositoryProvider)
                      .unfollow(creators[index].id),
                ),
              ),
      );
    if (widget.embedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('关注')),
      body: content,
    );
  }

  Future<void> _refreshAll(List<FollowedCreator> creators) async {
    await Future.wait(creators.map(_refresh));
  }

  Future<void> _refresh(FollowedCreator creator) async {
    setState(() => _loading.add(creator.id));
    try {
      final results =
          await ref.read(followedCreatorRepositoryProvider).refresh(creator);
      if (mounted) setState(() => _results[creator.id] = results);
    } finally {
      if (mounted) setState(() => _loading.remove(creator.id));
    }
  }
}

class _CreatorSection extends StatelessWidget {
  const _CreatorSection({
    required this.creator,
    required this.galleries,
    required this.loading,
    required this.onRefresh,
    required this.onUnfollow,
  });

  final FollowedCreator creator;
  final List<Gallery> galleries;
  final bool loading;
  final VoidCallback onRefresh;
  final VoidCallback onUnfollow;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(creator.kind == FollowedCreatorKind.artist
                    ? Icons.brush_outlined
                    : Icons.person_outline),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(creator.displayName,
                        style: Theme.of(context).textTheme.titleMedium)),
                IconButton(
                    tooltip: '取消关注',
                    onPressed: onUnfollow,
                    icon: const Icon(Icons.person_remove_outlined)),
              ],
            ),
            Text(creator.kind == FollowedCreatorKind.artist ? '作者' : '发布者'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: loading ? null : onRefresh,
              icon: loading
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh),
              label: const Text('检查新作品'),
            ),
            if (galleries.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: galleries.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final gallery = galleries[index];
                    return SizedBox(
                      width: 104,
                      child: InkWell(
                        onTap: () => context.push(
                            '/gallery/${gallery.key.source.storageValue}/${gallery.key.gid}',
                            extra: gallery),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: GalleryCover(gallery: gallery)),
                            const SizedBox(height: 5),
                            Text(gallery.title,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
