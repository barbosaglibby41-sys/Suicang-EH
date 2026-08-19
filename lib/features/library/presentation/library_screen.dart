import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/layout/adaptive_layout.dart';
import '../../favorites/presentation/cloud_favorites_screen.dart';
import '../../follows/presentation/followed_creators_screen.dart';
import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/presentation/widgets/gallery_cover.dart';
import '../../gallery/presentation/widgets/gallery_card_meta.dart';
import '../domain/entities/library_filter.dart';
import 'providers/library_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  var _filter = const LibraryFilter();

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteGalleriesProvider(_filter));
    final history = ref.watch(historyGalleriesProvider(_filter));
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('书架'),
          actions: [
            IconButton(
              tooltip: '筛选与排序',
              onPressed: _showFilterSheet,
              icon: const Icon(Icons.sort_outlined),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: '本地收藏'),
              Tab(text: '历史'),
              Tab(text: '账户收藏'),
              Tab(text: '关注'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GalleryCollection(
              data: favorites,
              emptyText: '还没有本地收藏。',
              filter: _filter,
            ),
            _GalleryCollection(
              data: history,
              emptyText: '最近打开的作品会显示在这里。',
              filter: _filter,
            ),
            _CloudFavoritesCollection(filter: _filter),
            const _FollowedCreatorsCollection(),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    final next = await showModalBottomSheet<LibraryFilter>(
      context: context,
      builder: (context) => _LibraryFilterSheet(initial: _filter),
    );
    if (next != null && mounted) setState(() => _filter = next);
  }
}

class _CloudFavoritesCollection extends StatelessWidget {
  const _CloudFavoritesCollection({required this.filter});

  final LibraryFilter filter;

  @override
  Widget build(BuildContext context) {
    return CloudFavoritesScreen(
      embedded: true,
      sort: filter.sort,
      date: filter.date,
    );
  }
}

class _FollowedCreatorsCollection extends StatelessWidget {
  const _FollowedCreatorsCollection();

  @override
  Widget build(BuildContext context) => const FollowedCreatorsScreen(embedded: true);
}

class _GalleryCollection extends StatelessWidget {
  const _GalleryCollection({
    required this.data,
    required this.emptyText,
    required this.filter,
  });

  final AsyncValue<List<Gallery>> data;
  final String emptyText;
  final LibraryFilter filter;

  @override
  Widget build(BuildContext context) {
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('书架暂时无法读取。')),
      data: (items) => items.isEmpty
          ? Center(child: Text(emptyText))
          : LayoutBuilder(
              builder: (context, _) {
                final columns = AdaptiveLayout.gridColumns(context);
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.57,
                  ),
                  itemBuilder: (context, index) =>
                      _GalleryCard(gallery: items[index]),
                );
              },
            ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.gallery});

  final Gallery gallery;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: gallery.title,
      hint: '打开作品详情',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          '/gallery/${gallery.key.source.storageValue}/${gallery.key.gid}',
          extra: gallery,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'library-cover-${gallery.key.stableId}',
                child: GalleryCover(gallery: gallery),
              ),
            ),
            const SizedBox(height: 8),
            Text(gallery.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            GalleryCardMeta(gallery: gallery),
          ],
        ),
      ),
    );
  }
}

class _LibraryFilterSheet extends StatefulWidget {
  const _LibraryFilterSheet({required this.initial});

  final LibraryFilter initial;

  @override
  State<_LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<_LibraryFilterSheet> {
  late LibraryFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('排序', style: Theme.of(context).textTheme.headlineSmall),
          RadioListTile<LibrarySort>(
            value: LibrarySort.favoriteTime,
            groupValue: _filter.sort,
            title: const Text('收藏时间'),
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(sort: value),
            ),
          ),
          RadioListTile<LibrarySort>(
            value: LibrarySort.publishedTime,
            groupValue: _filter.sort,
            title: const Text('发布时间'),
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(sort: value),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(_filter.date == null
                ? '选择日期'
                : '${_filter.date!.year}-${_filter.date!.month.toString().padLeft(2, '0')}-${_filter.date!.day.toString().padLeft(2, '0')}'),
            trailing: _filter.date == null
                ? const Icon(Icons.chevron_right)
                : IconButton(
                    tooltip: '清除日期',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(
                      () => _filter = _filter.copyWith(clearDate: true),
                    ),
                  ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () =>
                    setState(() => _filter = const LibraryFilter()),
                child: const Text('重置'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_filter),
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _filter.date ?? now,
      firstDate: DateTime(2010),
      lastDate: now,
    );
    if (picked != null && mounted)
      setState(() => _filter = _filter.copyWith(date: picked));
  }
}
