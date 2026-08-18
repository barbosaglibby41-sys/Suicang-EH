import 'dart:async';

import '../entities/reader_models.dart';
import '../page_source/page_source.dart';

class MangaReaderEngine {
  MangaReaderEngine({
    required PageSource pageSource,
    required ReaderState initialState,
    this.preloadRadius = 2,
    this.onProgress,
  })  : _pageSource = pageSource,
        _state = initialState;

  final PageSource _pageSource;
  final int preloadRadius;
  final Future<void> Function(int index)? onProgress;
  final _stateController = StreamController<ReaderState>.broadcast();
  final _preloadController = StreamController<int>.broadcast();
  ReaderState _state;
  Timer? _progressDebounce;

  ReaderState get state => _state;
  Stream<ReaderState> get states => _stateController.stream;
  Stream<int> get preloadRequests => _preloadController.stream;

  Future<void> initialize() async {
    final count = await _pageSource.pageCount();
    _update(_state.copyWith(
      pageCount: count,
      currentIndex: _clampIndex(_state.currentIndex, count),
    ));
    await _scheduleAround(_state.currentIndex);
  }

  Future<ReaderPage> pageAt(int index) async {
    final safeIndex = _clampIndex(index, _state.pageCount);
    final page = await _pageSource.pageAt(safeIndex);
    await _scheduleAround(safeIndex);
    return page;
  }

  Future<void> goTo(int index) async {
    final next = _clampIndex(index, _state.pageCount);
    if (next == _state.currentIndex) {
      return;
    }
    _update(_state.copyWith(currentIndex: next));
    _queueProgress();
    await _scheduleAround(next);
  }

  Future<void> next() => goTo(_state.currentIndex + 1);
  Future<void> previous() => goTo(_state.currentIndex - 1);

  void toggleControls() =>
      _update(_state.copyWith(controlsVisible: !_state.controlsVisible));

  void setMode(ReaderMode mode) => _update(_state.copyWith(mode: mode));
  void setDirection(ReaderDirection direction) =>
      _update(_state.copyWith(direction: direction));
  void setFit(ReaderFit fit) => _update(_state.copyWith(fit: fit));

  void setZoom(double zoom) =>
      _update(_state.copyWith(zoom: zoom.clamp(1, 4).toDouble()));

  Future<void> retryCurrentPage() async {
    await _pageSource.invalidate(_state.currentIndex);
    await pageAt(_state.currentIndex);
  }

  Future<void> flushProgress() async {
    _progressDebounce?.cancel();
    await onProgress?.call(_state.currentIndex);
  }

  Future<void> dispose() async {
    await flushProgress();
    await _stateController.close();
    await _preloadController.close();
  }

  void _update(ReaderState next) {
    _state = next;
    if (!_stateController.isClosed) {
      _stateController.add(next);
    }
  }

  void _queueProgress() {
    _progressDebounce?.cancel();
    _progressDebounce = Timer(const Duration(milliseconds: 300), () {
      onProgress?.call(_state.currentIndex);
    });
  }

  Future<void> _scheduleAround(int center) async {
    final first = center - preloadRadius;
    final last = center + preloadRadius;
    for (var index = first; index <= last; index++) {
      if (index >= 0 && index < _state.pageCount && index != center) {
        if (!_preloadController.isClosed) {
          _preloadController.add(index);
        }
      }
    }
  }

  int _clampIndex(int index, int count) {
    if (count <= 0) return 0;
    return index.clamp(0, count - 1).toInt();
  }
}
