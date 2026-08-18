import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/core/image/memory_image_cache.dart';

void main() {
  test('evicts least recently used entries by decoded cost', () {
    final cache = MemoryImageCache<String>(maxCostBytes: 10);
    cache.put('first', 'one', costBytes: 6);
    cache.put('second', 'two', costBytes: 4);
    expect(cache.get('first'), 'one');

    cache.put('third', 'three', costBytes: 4);

    expect(cache.get('first'), isNotNull);
    expect(cache.get('second'), isNull);
    expect(cache.get('third'), 'three');
    expect(cache.totalCostBytes, 10);
  });

  test('does not retain entries larger than the cache budget', () {
    final cache = MemoryImageCache<String>(maxCostBytes: 4);
    cache.put('large', 'image', costBytes: 5);

    expect(cache.length, 0);
    expect(cache.totalCostBytes, 0);
  });
}
