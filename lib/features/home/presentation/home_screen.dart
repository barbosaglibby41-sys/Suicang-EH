import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/image/image_request.dart';
import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/domain/entities/gallery_key.dart';
import '../../gallery/presentation/widgets/gallery_cover.dart';
import '../../tags/presentation/providers/tag_translation_providers.dart';
import '../../search/presentation/providers/search_history_providers.dart';
import 'notifiers/discovery_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoveryNotifierProvider.notifier).load();
    });
  }

  String _currentToken(String value) {
    final parts = value.split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.last;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryNotifierProvider);
    final notifier = ref.read(discoveryNotifierProvider.notifier);
    final token = _currentToken(_searchController.text);
    final tagRepository = ref.watch(tagTranslationRepositoryProvider);
    final suggestions = tagRepository.isReady && token.isNotEmpty
        ? tagRepository.suggestions(token)
        : const [];
    final history = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => state.isSearch
          ? notifier.search(state.query)
          : notifier.load(force: true),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TAROEH',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('发现', style: theme.textTheme.headlineSmall),
                          ],
                        ),
                      ),
                      SegmentedButton<SiteSource>(
                        segments: const [
                          ButtonSegment(
                            value: SiteSource.eHentai,
                            label: Text('E'),
                          ),
                          ButtonSegment(
                            value: SiteSource.exHentai,
                            label: Text('EX'),
                          ),
                        ],
                        selected: {state.source},
                        onSelectionChanged: (value) =>
                            notifier.switchSource(value.single),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: state.isLoading ? null : notifier.loadPopular,
                        icon: const Icon(Icons.local_fire_department_outlined),
                        label: const Text('热门'),
                      ),
                      OutlinedButton.icon(
                        onPressed: state.isLoading ? null : notifier.loadRandom,
                        icon: const Icon(Icons.casino_outlined),
                        label: const Text('随机'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/rankings'),
                        icon: const Icon(Icons.bar_chart_outlined),
                        label: const Text('排行'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SearchBar(
                    controller: _searchController,
                    leading: const Icon(Icons.search),
                    hintText: '搜索标题、作者或标签',
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          tooltip: '清除搜索',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            notifier.load(force: true);
                            setState(() {});
                          },
                        ),
                    ],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: notifier.search,
                  ),
                  if (suggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Card(
                        child: Column(
                          children: [
                            for (final tag in suggestions)
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.sell_outlined),
                                title: Text(tag.name),
                                subtitle: Text(tag.rawName),
                                onTap: () {
                                  final query = _searchController.text;
                                  final token = _currentToken(query);
                                  final start = query.length - token.length;
                                  _searchController.text =
                                      '${query.substring(0, start)}${tag.key} ';
                                  _searchController.selection = TextSelection.collapsed(
                                    offset: _searchController.text.length,
                                  );
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (token.isEmpty)
                    history.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (entries) => entries.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('最近搜索', style: theme.textTheme.titleSmall),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => ref
                                            .read(searchHistoryRepositoryProvider)
                                            .clear(),
                                        child: const Text('清除'),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final entry in entries)
                                        InputChip(
                                          label: Text(entry.query),
                                          onPressed: () {
                                            _searchController.text = entry.query;
                                            _searchController.selection =
                                                TextSelection.collapsed(
                                              offset: entry.query.length,
                                            );
                                            notifier.search(entry.query);
                                          },
                                          onDeleted: () => ref
                                              .read(searchHistoryRepositoryProvider)
                                              .remove(entry.id),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  const SizedBox(height: 18),
                  Text(
                    state.isSearch ? '搜索结果' : '最新发现',
                    style: theme.textTheme.titleLarge,
                  ),
                  if (state.isSearch) ...[
                    const SizedBox(height: 4),
                    Text(
                      '“${state.query}”',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (state.isLoading && state.galleries.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.isEmpty)
            SliverFillRemaining(
              child: _EmptyResult(
                message: state.errorMessage ?? '没有找到可显示的作品。',
                onRetry: () => state.isSearch
                    ? notifier.search(state.query)
                    : notifier.load(force: true),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width >= 1000
                      ? 5
                      : width >= 680
                          ? 4
                          : 2;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.galleries.length) {
                          return _LoadMoreTile(
                            isLoading: state.isLoadingMore,
                            hasMore: state.hasMore,
                            onPressed: notifier.loadMore,
                          );
                        }
                        final gallery = state.galleries[index];
                        return _GalleryTile(gallery: gallery);
                      },
                      childCount: state.galleries.length + 1,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.56,
                    ),
                  );
                },
              ),
            ),
          if (state.errorMessage != null && state.galleries.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: _ErrorBanner(
                  message: state.errorMessage!,
                  onRetry: notifier.loadMore,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.gallery});

  final Gallery gallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: gallery.title,
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
                tag: 'gallery-cover-${gallery.key.stableId}',
                child: GalleryCover(
                  gallery: gallery,
                  variant: ImageVariant.cover,
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              gallery.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [if (gallery.category.isNotEmpty) gallery.category, if (gallery.pageCount > 0) '${gallery.pageCount} 页'].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({
    required this.isLoading,
    required this.hasMore,
    required this.onPressed,
  });

  final bool isLoading;
  final bool hasMore;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const SizedBox.shrink();
    }
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isLoading ? null : onPressed,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : const Icon(Icons.add, semanticLabel: '加载更多'),
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_outlined, size: 44),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
            IconButton(
              tooltip: '重试',
              onPressed: onRetry,
              icon: Icon(Icons.refresh, color: colorScheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }
}
