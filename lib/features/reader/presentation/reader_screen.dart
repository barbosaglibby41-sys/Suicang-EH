import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/image/image_providers.dart';
import '../../../core/image/image_request.dart';
import '../../../core/image/media_kind.dart';
import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/domain/entities/gallery_key.dart';
import '../domain/engine/manga_reader_engine.dart';
import '../domain/entities/reader_models.dart';
import '../domain/page_source/page_source.dart';
import 'widgets/reader_media.dart';
import 'providers/keep_screen_on_providers.dart';
import 'providers/reader_controller.dart';
import 'providers/reader_preferences_providers.dart';
import 'providers/reading_progress_providers.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    required this.gallery,
    this.initialIndex = 0,
    this.pageSource,
    super.key,
  });

  final Gallery gallery;
  final int initialIndex;
  final PageSource? pageSource;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  MangaReaderEngine? _engine;
  StreamSubscription<ReaderState>? _states;
  StreamSubscription<int>? _preloads;
  ReaderState? _state;
  late final ReaderKeepScreenOnController _keepScreenOn;
  final _pages = <int, Future<_LoadedPage>>{};
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _keepScreenOn = ref.read(readerKeepScreenOnControllerProvider);
    unawaited(_enterImmersiveReader());
    unawaited(_initialize());
  }

  @override
  void dispose() {
    _states?.cancel();
    _preloads?.cancel();
    unawaited(_keepScreenOn.dispose());
    unawaited(_exitImmersiveReader());
    super.dispose();
  }

  Future<void> _enterImmersiveReader() {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitImmersiveReader() {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final engine = _engine;
    final state = _state ?? engine?.state;
    if (!_ready || engine == null || state == null || state.pageCount == 0) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.gallery.title, maxLines: 1),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: state.mode == ReaderMode.vertical
                ? _VerticalReader(
                    engine: engine,
                    state: state,
                    loadPage: _loadPage,
                  )
                : _HorizontalReader(
                    engine: engine,
                    state: state,
                    loadPage: _loadPage,
                  ),
          ),
          if (state.controlsVisible)
            _ReaderControls(
              title: widget.gallery.title,
              state: state,
              onClose: () => Navigator.of(context).maybePop(),
              onToggleMode: () => _updateMode(
                engine,
                state.mode == ReaderMode.horizontal
                    ? ReaderMode.vertical
                    : ReaderMode.horizontal,
              ),
              onToggleDirection: () => _updateDirection(
                engine,
                state.direction == ReaderDirection.ltr
                    ? ReaderDirection.rtl
                    : ReaderDirection.ltr,
              ),
              onToggleFit: () => _updateFit(
                engine,
                state.fit == ReaderFit.contain
                    ? ReaderFit.cover
                    : ReaderFit.contain,
              ),
              onJumpTo: engine.goTo,
            ),
        ],
      ),
    );
  }

  Future<void> _initialize() async {
    final preferences = await ref.read(readerPreferencesProvider.future);
    await _keepScreenOn.sync(
      readerVisible: true,
      preference: preferences.keepScreenOn,
    );
    final saved = await ref
        .read(readingProgressRepositoryProvider)
        .get(widget.gallery.key);
    if (!mounted) return;
    final config = ReaderSessionConfig(
      gallery: widget.gallery,
      initialIndex: widget.initialIndex > 0
          ? widget.initialIndex
          : (saved?.pageIndex ?? 0),
      preferences: preferences,
      pageSource: widget.pageSource,
    );
    final engine = ref.read(readerEngineProvider(config));
    _engine = engine;
    _state = engine.state;
    _states = engine.states.listen((state) {
      if (!mounted) return;
      setState(() => _state = state);
    });
    _preloads = engine.preloadRequests.listen((index) {
      unawaited(_loadPage(index));
    });
    await engine.initialize();
    if (!mounted) return;
    setState(() => _ready = true);
    await _loadPage(engine.state.currentIndex);
  }

  Future<void> _updateMode(MangaReaderEngine engine, ReaderMode mode) async {
    engine.setMode(mode);
    final current = await ref.read(readerPreferencesProvider.future);
    await ref
        .read(readerPreferencesProvider.notifier)
        .setPreferences(current.copyWith(mode: mode));
  }

  Future<void> _updateDirection(
    MangaReaderEngine engine,
    ReaderDirection direction,
  ) async {
    engine.setDirection(direction);
    final current = await ref.read(readerPreferencesProvider.future);
    await ref
        .read(readerPreferencesProvider.notifier)
        .setPreferences(current.copyWith(direction: direction));
  }

  Future<void> _updateFit(MangaReaderEngine engine, ReaderFit fit) async {
    engine.setFit(fit);
    final current = await ref.read(readerPreferencesProvider.future);
    await ref
        .read(readerPreferencesProvider.notifier)
        .setPreferences(current.copyWith(fit: fit));
  }

  Future<_LoadedPage> _loadPage(int index) {
    final engine = _engine;
    if (engine == null) {
      return Future<_LoadedPage>.error(
          StateError('Reader is not initialized.'));
    }
    return _pages.putIfAbsent(index, () async {
      final page = await engine.pageAt(index);
      if (MediaKindResolver.fromUri(page.source) == MediaKind.video) {
        return _LoadedPage(url: page.source, bytes: Uint8List(0));
      }
      final pipeline = ref.read(imagePipelineProvider);
      final bytes = await pipeline.load(
        ImageRequest(
          url: page.source,
          referer: widget.gallery.sourceUrl,
          variant: ImageVariant.reader,
          targetPixels: 1600,
        ),
        source: widget.gallery.key.source,
      );
      return _LoadedPage(url: page.source, bytes: bytes);
    });
  }
}

class _HorizontalReader extends StatefulWidget {
  const _HorizontalReader({
    required this.engine,
    required this.state,
    required this.loadPage,
  });

  final MangaReaderEngine engine;
  final ReaderState state;
  final Future<_LoadedPage> Function(int index) loadPage;

  @override
  State<_HorizontalReader> createState() => _HorizontalReaderState();
}

class _HorizontalReaderState extends State<_HorizontalReader> {
  late PageController _controller;
  var _lastSyncedIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastSyncedIndex = widget.state.currentIndex;
    _controller = PageController(initialPage: _lastSyncedIndex);
  }

  @override
  void didUpdateWidget(covariant _HorizontalReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = widget.state.currentIndex;
    if (nextIndex != _lastSyncedIndex && _controller.hasClients) {
      _lastSyncedIndex = nextIndex;
      _controller.jumpToPage(nextIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      reverse: widget.state.direction == ReaderDirection.rtl,
      itemCount: widget.state.pageCount,
      onPageChanged: (index) {
        _lastSyncedIndex = index;
        unawaited(widget.engine.goTo(index));
      },
      itemBuilder: (context, index) => _ReaderPage(
        future: widget.loadPage(index),
        fit: widget.state.fit,
        zoom: widget.state.zoom,
        onTap: widget.engine.toggleControls,
        onDoubleTap: () => widget.engine.setZoom(
          widget.state.zoom == 1 ? 2 : 1,
        ),
        source: widget.engine.state.galleryKey.source,
      ),
    );
  }
}

class _VerticalReader extends StatelessWidget {
  const _VerticalReader({
    required this.engine,
    required this.state,
    required this.loadPage,
  });

  final MangaReaderEngine engine;
  final ReaderState state;
  final Future<_LoadedPage> Function(int index) loadPage;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.pageCount,
      itemBuilder: (context, index) => _ReaderPage(
        future: loadPage(index),
        fit: state.fit,
        zoom: state.zoom,
        onTap: engine.toggleControls,
        onDoubleTap: () => engine.setZoom(state.zoom == 1 ? 2 : 1),
        source: engine.state.galleryKey.source,
      ),
    );
  }
}

class _ReaderPage extends StatelessWidget {
  const _ReaderPage({
    required this.future,
    required this.fit,
    required this.zoom,
    required this.onTap,
    required this.onDoubleTap,
    required this.source,
  });

  final Future<_LoadedPage> future;
  final ReaderFit fit;
  final double zoom;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final SiteSource source;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: FutureBuilder<_LoadedPage>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox(
              height: 320,
              child: Center(child: Icon(Icons.broken_image_outlined)),
            );
          }
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final page = snapshot.data!;
          return ReaderMedia(
            url: page.url,
            bytes: page.bytes,
            source: source,
            fit: fit,
            zoom: zoom,
          );
        },
      ),
    );
  }
}

class _ReaderControls extends StatefulWidget {
  const _ReaderControls({
    required this.title,
    required this.state,
    required this.onClose,
    required this.onToggleMode,
    required this.onToggleDirection,
    required this.onToggleFit,
    required this.onJumpTo,
  });

  final String title;
  final ReaderState state;
  final VoidCallback onClose;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleDirection;
  final VoidCallback onToggleFit;
  final Future<void> Function(int index) onJumpTo;

  @override
  State<_ReaderControls> createState() => _ReaderControlsState();
}

class _ReaderControlsState extends State<_ReaderControls> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.state.currentIndex.toDouble();
  }

  @override
  void didUpdateWidget(covariant _ReaderControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sliderValue = widget.state.currentIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Positioned.fill(
      child: Column(
        children: [
          Material(
            color: Colors.black.withValues(alpha: 0.78),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    tooltip: '关闭',
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    tooltip: '横向或纵向阅读',
                    onPressed: widget.onToggleMode,
                    icon: Icon(
                      state.mode == ReaderMode.horizontal
                          ? Icons.view_agenda_outlined
                          : Icons.swap_horiz,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    tooltip: '切换左右阅读方向',
                    onPressed: widget.onToggleDirection,
                    icon: Icon(
                      state.direction == ReaderDirection.ltr
                          ? Icons.format_textdirection_l_to_r
                          : Icons.format_textdirection_r_to_l,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    tooltip: '切换适配模式',
                    onPressed: widget.onToggleFit,
                    icon: const Icon(Icons.fit_screen_outlined,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.black.withValues(alpha: 0.78),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Semantics(
                          liveRegion: true,
                          label:
                              '第 ${state.currentIndex + 1} 页，共 ${state.pageCount} 页，完成 ${(state.progress * 100).round()}%',
                          child: Text(
                            '${state.currentIndex + 1} / ${state.pageCount}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: state.progress,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '${(state.progress * 100).round()}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Slider(
                      value: _sliderValue,
                      min: 0,
                      max: (state.pageCount - 1).toDouble(),
                      divisions:
                          state.pageCount > 1 ? state.pageCount - 1 : null,
                      onChanged: (value) =>
                          setState(() => _sliderValue = value),
                      onChangeEnd: (value) => widget.onJumpTo(value.round()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedPage {
  const _LoadedPage({required this.url, required this.bytes});

  final Uri url;
  final Uint8List bytes;
}
