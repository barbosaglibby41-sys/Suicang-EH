import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/page_sources/online_page_source.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../domain/engine/manga_reader_engine.dart';
import '../../domain/entities/reading_progress.dart';
import 'reading_progress_providers.dart';
import '../../domain/entities/reader_models.dart';
import '../../domain/entities/reader_preferences.dart';
import '../../domain/page_source/page_source.dart';

final readerEngineProvider =
    Provider.family<MangaReaderEngine, ReaderSessionConfig>((ref, config) {
  final repository = ref.read(galleryRepositoryProvider);
  final pageSource = config.pageSource ??
      OnlinePageSource(gallery: config.gallery, repository: repository);
  late final MangaReaderEngine engine;
  engine = MangaReaderEngine(
    pageSource: pageSource,
    initialState: ReaderState(
      galleryKey: config.gallery.key,
      mode: config.preferences.mode,
      direction: config.preferences.direction,
      fit: config.preferences.fit,
      pageCount: config.gallery.pageCount,
      currentIndex: config.initialIndex,
    ),
    onProgress: (index) async {
      await ref.read(readingProgressRepositoryProvider).save(
            ReadingProgress(
              galleryKey: config.gallery.key,
              pageIndex: index,
              pageCount: engine.state.pageCount,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      await config.onProgress?.call(index);
    },
  );
  ref.onDispose(() {
    unawaited(engine.dispose());
  });
  return engine;
});

class ReaderSessionConfig {
  const ReaderSessionConfig({
    required this.gallery,
    this.initialIndex = 0,
    required this.preferences,
    this.pageSource,
    this.onProgress,
  });

  final Gallery gallery;
  final int initialIndex;
  final ReaderPreferences preferences;
  final PageSource? pageSource;
  final Future<void> Function(int index)? onProgress;

  @override
  bool operator ==(Object other) =>
      other is ReaderSessionConfig &&
      other.gallery.key == gallery.key &&
      other.initialIndex == initialIndex &&
      other.preferences.mode == preferences.mode &&
      other.preferences.direction == preferences.direction &&
      other.preferences.fit == preferences.fit &&
      other.pageSource == pageSource;

  @override
  int get hashCode => Object.hash(
        gallery.key,
        initialIndex,
        preferences.mode,
        preferences.direction,
        preferences.fit,
        pageSource,
      );
}
