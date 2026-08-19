import 'dart:async';

class DecodeScheduler {
  DecodeScheduler({this.maximumConcurrentDecodes = 2});

  final int maximumConcurrentDecodes;
  final _visible = <_QueuedDecode<dynamic>>[];
  final _prefetch = <_QueuedDecode<dynamic>>[];
  var _active = 0;

  Future<T> schedule<T>({
    required bool visible,
    required Future<T> Function() operation,
  }) {
    final queued = _QueuedDecode<T>(operation);
    (visible ? _visible : _prefetch).add(queued);
    _drain();
    return queued.completer.future;
  }

  void _drain() {
    while (_active < maximumConcurrentDecodes) {
      final next = _visible.isNotEmpty
          ? _visible.removeAt(0)
          : _prefetch.isNotEmpty
              ? _prefetch.removeAt(0)
              : null;
      if (next == null) return;
      _active += 1;
      next.run().whenComplete(() {
        _active -= 1;
        _drain();
      });
    }
  }
}

class _QueuedDecode<T> {
  _QueuedDecode(this.operation);

  final Future<T> Function() operation;
  final completer = Completer<T>();

  Future<void> run() async {
    try {
      completer.complete(await operation());
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }
  }
}
