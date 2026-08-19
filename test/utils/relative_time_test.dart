import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/utils/relative_time.dart';

void main() {
  final now = DateTime.utc(2026, 8, 19, 10, 0, 0);

  test('formats elapsed time with second precision', () {
    expect(RelativeTime.format(now.subtract(const Duration(seconds: 42)), now: now), '42 秒前');
    expect(RelativeTime.format(now.subtract(const Duration(minutes: 7)), now: now), '7 分钟前');
    expect(RelativeTime.format(now.subtract(const Duration(hours: 3, minutes: 12)), now: now), '3 小时 12 分钟前');
  });
}
