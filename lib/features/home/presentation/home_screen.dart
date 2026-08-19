import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/image/image_request.dart';
import '../../../app/layout/adaptive_layout.dart';
import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/domain/entities/gallery_key.dart';
import '../../gallery/presentation/widgets/gallery_cover.dart';
import '../../gallery/presentation/widgets/gallery_card_meta.dart';
import '../../tags/presentation/providers/tag_translation_providers.dart';
import '../../search/presentation/providers/search_history_providers.dart';
import '../../settings/presentation/providers/site_preferences_providers.dart';
import 'notifiers/discovery_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  var _initialized = false;
  String? _appliedRouteQuery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeQuery = GoRouterState.of(context).uri.queryParameters['query'];
    _applyRouteQuery(routeQuery);
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final preferences = await ref.read(sitePreferencesProvider.future);
      if (!mounted) return;
      final notifier = ref.read(discoveryNotifierProvider.notifier);
      await notifier.initializeSource(preferences.source);
      if (_searchController.text.trim().isNotEmpty) {
        await notifier.search(_searchController.text);
      }
    });
  }

  void _applyRouteQuery(String? value) {
    final query = value?.trim();
    if (query == null || query.isEmpty || query == _appliedRouteQuery) return;
    _appliedRouteQuery = query;
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(discoveryNotifierProvider.notifier).search(query);
    });
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _popSearchIfNeeded() {
    _dismissKeyboard();
    if (context.canPop()) {
      context.pop();
    }
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
          : state.isRandom
              ? notifier.loadRandom(fresh: true)
              : notifier.load(force: true),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (state.isSearch && context.canPop())
                        IconButton(
                          tooltip: '返回详情',
                          onPressed: _popSearchIfNeeded,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SUICANG EH',
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
                        onPressed:
                            state.isLoading ? null : notifier.loadPopular,
                        icon: const Icon(Icons.local_fire_department_outlined),
                        label: const Text('热门'),
                      ),
                      OutlinedButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => notifier.loadRandom(fresh: true),
                        icon: const Icon(Icons.casino_outlined),
                        label: Text(state.isRandom ? '换一批' : '随机'),
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
                            _dismissKeyboard();
                            notifier.load(force: true);
                            setState(() {});
                          },
                        ),
                    ],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (value) {
                      _dismissKeyboard();
                      notifier.search(value);
                    },
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
                                subtitle: Text('${tag.namespace} : ${tag.key}'),
                                onTap: () {
                                  final query = _searchController.text;
                                  final token = _currentToken(query);
                                  final start = query.length - token.length;
                                  final siteTag =
                                      '${tag.namespace}:"${tag.key}\$"';
                                  _searchController.text =
                                      '${query.substring(0, start)}$siteTag ';
                                  _searchController.selection =
                                      TextSelection.collapsed(
                                    offset: _searchController.text.length,
                                  );
                                  _dismissKeyboard();
                                  setState(() {});
                                  notifier.search(_searchController.text.trim());
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
                                      Text('最近搜索',
                                          style: theme.textTheme.titleSmall),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => ref
                                            .read(
                                                searchHistoryRepositoryProvider)
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
                                            _searchController.text =
                                                entry.query;
                                            _searchController.selection =
                                                TextSelection.collapsed(
                                              offset: entry.query.length,
                                            );
                                            notifier.search(entry.query);
                                          },
                                          onDeleted: () => ref
                                              .read(
                                                  searchHistoryRepositoryProvider)
                                              .remove(entry.id),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        state.isSearch
                            ? '搜索结果'
                            : state.isRandom
                                ? '随机探索'
                                : '最新发现',
                        style: theme.textTheme.titleLarge,
                      ),
                      if (state.isRandom) ...[
                        const SizedBox(width: 8),
                        Text(
                          '第 ${state.randomRound} 轮 · ${state.galleries.length} 部',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
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
                builder: (context, _) {
                  final columns = AdaptiveLayout.gridColumns(context);
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
                      childCount:
                          state.galleries.length + (state.hasMore ? 1 : 0),
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
            GalleryCardMeta(gallery: gallery),
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
