import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/image/image_pipeline.dart';
import '../../../core/image/image_providers.dart';
import '../../../core/image/image_request.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../domain/engine/manga_reader_engine.dart';
import '../domain/page_source/page_source.dart';
import 'providers/reader_controller.dart';
import 'providers/reading_progress_providers.dart';
import '../domain/entities/reader_models.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    required this.gallery,
    this.pageSource,
    super.key,
  });

  final Gallery gallery;
  final PageSource? pageSource;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  MangaReaderEngine? _engine;
  StreamSubscription<ReaderState>? _states;
  StreamSubscription<int>? _preloads;
  ReaderState? _state;
  final _pages = <int, Future<Uint8List>>{};
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void dispose() {
    _states?.cancel();
    _preloads?.cancel();
    super.dispose();
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
          SafeArea(
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
          if (state.controlsVisible) _ReaderControls(
            title: widget.gallery.title,
            state: state,
            onClose: () => Navigator.of(context).maybePop(),
            onToggleMode: () => engine.setMode(
              state.mode == ReaderMode.horizontal
                  ? ReaderMode.vertical
                  : ReaderMode.horizontal,
            ),
            onToggleFit: () => engine.setFit(
              state.fit == ReaderFit.contain ? ReaderFit.cover : ReaderFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initialize() async {
    final saved = await ref
        .read(readingProgressRepositoryProvider)
        .get(widget.gallery.key);
    if (!mounted) return;
    final config = ReaderSessionConfig(
      gallery: widget.gallery,
      initialIndex: saved?.pageIndex ?? 0,
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

  Future<Uint8List> _loadPage(int index) {
    final engine = _engine;
    if (engine == null) {
      return Future<Uint8List>.error(StateError('Reader is not initialized.'));
    }
    return _pages.putIfAbsent(index, () async {
      final page = await engine.pageAt(index);
      final pipeline = ref.read(imagePipelineProvider);
      return pipeline.load(
        ImageRequest(
          url: page.source,
          referer: widget.gallery.sourceUrl,
          variant: ImageVariant.reader,
          targetPixels: 1600,
        ),
        source: widget.gallery.key.source,
      );
    });
  }
}

class _HorizontalReader extends StatelessWidget {
  const _HorizontalReader({required this.engine, required this.state, required this.loadPage});

  final MangaReaderEngine engine;
  final ReaderState state;
  final Future<Uint8List> Function(int index) loadPage;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(initialPage: state.currentIndex),
      reverse: state.direction == ReaderDirection.rtl,
      itemCount: state.pageCount,
      onPageChanged: engine.goTo,
      itemBuilder: (context, index) => _ReaderPage(
        future: loadPage(index),
        fit: state.fit,
        zoom: state.zoom,
        onTap: engine.toggleControls,
      ),
    );
  }
}

class _VerticalReader extends StatelessWidget {
  const _VerticalReader({required this.engine, required this.state, required this.loadPage});

  final MangaReaderEngine engine;
  final ReaderState state;
  final Future<Uint8List> Function(int index) loadPage;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.pageCount,
      itemBuilder: (context, index) => _ReaderPage(
        future: loadPage(index),
        fit: state.fit,
        zoom: state.zoom,
        onTap: engine.toggleControls,
      ),
    );
  }
}

class _ReaderPage extends StatelessWidget {
  const _ReaderPage({required this.future, required this.fit, required this.zoom, required this.onTap});

  final Future<Uint8List> future;
  final ReaderFit fit;
  final double zoom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onTap,
      child: FutureBuilder<Uint8List>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(height: 320, child: Center(child: CircularProgressIndicator()));
          }
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            scaleEnabled: true,
            child: Image.memory(
              snapshot.data!,
              fit: fit == ReaderFit.contain ? BoxFit.contain : BoxFit.cover,
              width: double.infinity,
              filterQuality: FilterQuality.high,
            ),
          );
        },
      ),
    );
  }
}

class _ReaderControls extends StatelessWidget {
  const _ReaderControls({required this.title, required this.state, required this.onClose, required this.onToggleMode, required this.onToggleFit});

  final String title;
  final ReaderState state;
  final VoidCallback onClose;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleFit;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Column(
          children: [
            Material(
              color: Colors.black.withValues(alpha: 0.78),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(tooltip: '关闭', onPressed: onClose, icon: const Icon(Icons.close, color: Colors.white)),
                    Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white))),
                    IconButton(tooltip: '切换阅读方向', onPressed: onToggleMode, icon: Icon(state.mode == ReaderMode.horizontal ? Icons.view_agenda_outlined : Icons.swap_horiz, color: Colors.white)),
                    IconButton(tooltip: '切换适配模式', onPressed: onToggleFit, icon: const Icon(Icons.fit_screen_outlined, color: Colors.white)),
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
                  child: Row(
                    children: [
                      Text('${state.currentIndex + 1} / ${state.pageCount}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 14),
                      Expanded(child: LinearProgressIndicator(value: state.progress, color: Colors.white, backgroundColor: Colors.white24)),
                      const SizedBox(width: 14),
                      Text('${(state.progress * 100).round()}%', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
