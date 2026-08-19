import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/reader/presentation/reader_fullscreen.dart';

void main() {
  test('enters immersive mode and restores edge-to-edge on exit', () async {
    final modes = <SystemUiMode>[];
    final orientations = <List<DeviceOrientation>>[];
    final controller = ReaderFullscreenController(
      setMode: (mode) async => modes.add(mode),
      setOrientations: (value) async => orientations.add(value),
    );

    await controller.enter();
    await controller.enter();
    expect(controller.isEntered, isTrue);
    expect(modes, [SystemUiMode.immersiveSticky]);
    expect(orientations, [<DeviceOrientation>[]]);

    await controller.exit();
    await controller.exit();
    expect(controller.isEntered, isFalse);
    expect(modes, [SystemUiMode.immersiveSticky, SystemUiMode.edgeToEdge]);
    expect(orientations, [<DeviceOrientation>[], <DeviceOrientation>[]]);
  });
}
