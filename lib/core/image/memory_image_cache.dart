class MemoryImageCache<T> {
  MemoryImageCache({this.maxCostBytes = 120 * 1024 * 1024});

  final int maxCostBytes;
  final _entries = <String, _Entry<T>>{};
  int _totalCost = 0;

  T? get(String key) {
    final entry = _entries.remove(key);
    if (entry == null) {
      return null;
    }
    _entries[key] = entry;
    return entry.value;
  }

  void put(String key, T value, {required int costBytes}) {
    final old = _entries.remove(key);
    if (old != null) {
      _totalCost -= old.costBytes;
    }
    if (costBytes > maxCostBytes) {
      return;
    }
    _entries[key] = _Entry(value, costBytes);
    _totalCost += costBytes;
    _evict();
  }

  void remove(String key) {
    final entry = _entries.remove(key);
    if (entry != null) {
      _totalCost -= entry.costBytes;
    }
  }

  void clear() {
    _entries.clear();
    _totalCost = 0;
  }

  int get length => _entries.length;
  int get totalCostBytes => _totalCost;

  void _evict() {
    while (_totalCost > maxCostBytes && _entries.isNotEmpty) {
      final firstKey = _entries.keys.first;
      final entry = _entries.remove(firstKey)!;
      _totalCost -= entry.costBytes;
    }
  }
}

class _Entry<T> {
  const _Entry(this.value, this.costBytes);

  final T value;
  final int costBytes;
}
