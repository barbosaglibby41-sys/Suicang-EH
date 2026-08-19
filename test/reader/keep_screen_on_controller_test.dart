import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/platform/keep_screen_on.dart';
import 'package:suicang_eh/features/reader/presentation/providers/keep_screen_on_providers.dart';

void main() {
  test('only enables native keep-screen-on for visible opted-in reader',
      () async {
    final platform = _FakeKeepScreenOn();
    final controller = ReaderKeepScreenOnController(platform);

    await controller.sync(readerVisible: true, preference: true);
    await controller.sync(readerVisible: true, preference: true);
    await controller.sync(readerVisible: true, preference: false);

    expect(platform.values, [true, false]);
  });

  test('resets native screen setting on dispose', () async {
    final platform = _FakeKeepScreenOn();
    final controller = ReaderKeepScreenOnController(platform);
    await controller.sync(readerVisible: true, preference: true);
    await controller.dispose();

    expect(platform.values, [true, false]);
  });
}

class _FakeKeepScreenOn implements KeepScreenOn {
  final values = <bool>[];

  @override
  Future<void> setEnabled(bool enabled) async => values.add(enabled);
}
