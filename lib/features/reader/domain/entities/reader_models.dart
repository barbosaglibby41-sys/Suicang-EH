import '../../../gallery/domain/entities/gallery_key.dart';

enum ReaderMode { horizontal, vertical }
enum ReaderDirection { ltr, rtl }
enum ReaderFit { contain, cover }

class ReaderPage {
  const ReaderPage({
    required this.index,
    required this.source,
  });

  final int index;
  final Uri source;
}

class ReaderState {
  const ReaderState({
    required this.galleryKey,
    required this.mode,
    required this.direction,
    required this.fit,
    required this.pageCount,
    required this.currentIndex,
    this.controlsVisible = true,
    this.zoom = 1,
  });

  final GalleryKey galleryKey;
  final ReaderMode mode;
  final ReaderDirection direction;
  final ReaderFit fit;
  final int pageCount;
  final int currentIndex;
  final bool controlsVisible;
  final double zoom;

  double get progress => pageCount == 0 ? 0 : (currentIndex + 1) / pageCount;

  ReaderState copyWith({
    ReaderMode? mode,
    ReaderDirection? direction,
    ReaderFit? fit,
    int? pageCount,
    int? currentIndex,
    bool? controlsVisible,
    double? zoom,
  }) {
    return ReaderState(
      galleryKey: galleryKey,
      mode: mode ?? this.mode,
      direction: direction ?? this.direction,
      fit: fit ?? this.fit,
      pageCount: pageCount ?? this.pageCount,
      currentIndex: currentIndex ?? this.currentIndex,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      zoom: zoom ?? this.zoom,
    );
  }
}
