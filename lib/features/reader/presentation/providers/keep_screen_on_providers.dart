import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/keep_screen_on.dart';
import '../../../../core/platform/native_keep_screen_on.dart';

final keepScreenOnProvider = Provider<KeepScreenOn>((ref) {
  return NativeKeepScreenOn();
});

class ReaderKeepScreenOnController {
  ReaderKeepScreenOnController(this._platform);

  final KeepScreenOn _platform;
  var _enabled = false;

  Future<void> sync({required bool readerVisible, required bool preference}) async {
    final next = readerVisible && preference;
    if (_enabled == next) return;
    _enabled = next;
    await _platform.setEnabled(next);
  }

  Future<void> dispose() async {
    if (!_enabled) return;
    _enabled = false;
    await _platform.setEnabled(false);
  }
}

final readerKeepScreenOnControllerProvider =
    Provider.autoDispose<ReaderKeepScreenOnController>((ref) {
  final controller = ReaderKeepScreenOnController(ref.watch(keepScreenOnProvider));
  ref.onDispose(controller.dispose);
  return controller;
});
