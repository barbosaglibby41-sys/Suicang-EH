import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/image/image_request.dart';
import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/presentation/widgets/gallery_cover.dart';
import '../../gallery/presentation/widgets/gallery_card_meta.dart';
import '../domain/entities/ranking_period.dart';
import 'providers/rankings_providers.dart';

class RankingsScreen extends ConsumerStatefulWidget {
  const RankingsScreen({super.key});

  @override
  ConsumerState<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends ConsumerState<RankingsScreen> {
  var _period = RankingPeriod.yesterday;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rankingsNotifierProvider.notifier).initialize(_period);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rankingsNotifierProvider);
    final notifier = ref.read(rankingsNotifierProvider.notifier);
    final galleries = state.galleries(_period);
    return Scaffold(
      appBar: AppBar(
        title: const Text('排行'),
        actions: [
          PopupMenuButton<RankingPeriod>(
            onSelected: (period) {
              setState(() => _period = period);
              notifier.load(period);
            },
            itemBuilder: (context) => [
              for (final period in RankingPeriod.values)
                PopupMenuItem(value: period, child: Text(period.label)),
            ],
          ),
        ],
      ),
      body: state.isLoading && galleries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : galleries.isEmpty
              ? Center(child: Text(state.errorMessage ?? '暂无排行数据'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      galleries.length + (state.canLoadMore(_period) ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == galleries.length) {
                      final loading = state.loadingMore.contains(_period);
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: loading
                              ? const CircularProgressIndicator()
                              : OutlinedButton.icon(
                                  onPressed: () => notifier.loadMore(_period),
                                  icon: const Icon(Icons.add),
                                  label: const Text('加载更多'),
                                ),
                        ),
                      );
                    }
                    return _RankingRow(
                      gallery: galleries[index],
                      rank: index + 1,
                    );
                  },
                ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.gallery, required this.rank});

  final Gallery gallery;
  final int rank;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => context.push(
          '/gallery/${gallery.key.source.storageValue}/${gallery.key.gid}',
          extra: gallery,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text('$rank', textAlign: TextAlign.center),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 54,
                height: 76,
                child: GalleryCover(
                  gallery: gallery,
                  variant: ImageVariant.thumbnail,
                  targetPixels: 240,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gallery.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      gallery.uploader.isEmpty ? '未知作者' : gallery.uploader,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 3),
                    GalleryCardMeta(gallery: gallery),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
