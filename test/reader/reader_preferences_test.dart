import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/reader/domain/entities/reader_models.dart';
import 'package:taro_eh_flutter/features/reader/domain/entities/reader_preferences.dart';

void main() {
  test('copies only changed reader preference fields', () {
    const initial = ReaderPreferences();
    final next = initial.copyWith(
      mode: ReaderMode.vertical,
      direction: ReaderDirection.rtl,
    );

    expect(next.mode, ReaderMode.vertical);
    expect(next.direction, ReaderDirection.rtl);
    expect(next.fit, ReaderFit.contain);
    expect(next.keepScreenOn, isTrue);
  });
}
