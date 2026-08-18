class RequestCoalescer<K, V> {
  final _inFlight = <K, Future<V>>{};

  Future<V> run(K key, Future<V> Function() operation) {
    final existing = _inFlight[key];
    if (existing != null) return existing;

    late final Future<V> future;
    future = operation().whenComplete(() {
      if (identical(_inFlight[key], future)) {
        _inFlight.remove(key);
      }
    });
    _inFlight[key] = future;
    return future;
  }

  int get activeCount => _inFlight.length;
}
