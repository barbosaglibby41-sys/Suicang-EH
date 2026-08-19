import 'package:flutter/services.dart';

class ReaderFullscreenController {
  ReaderFullscreenController({
    Future<void> Function(SystemUiMode mode)? setMode,
    Future<void> Function(List<DeviceOrientation> orientations)?
        setOrientations,
  })  : _setMode = setMode ?? SystemChrome.setEnabledSystemUIMode,
        _setOrientations =
            setOrientations ?? SystemChrome.setPreferredOrientations;

  final Future<void> Function(SystemUiMode mode) _setMode;
  final Future<void> Function(List<DeviceOrientation> orientations)
      _setOrientations;
  var _entered = false;

  bool get isEntered => _entered;

  Future<void> enter() async {
    if (_entered) return;
    _entered = true;
    await _setOrientations(const <DeviceOrientation>[]);
    await _setMode(SystemUiMode.immersiveSticky);
  }

  Future<void> exit() async {
    if (!_entered) return;
    _entered = false;
    await _setMode(SystemUiMode.edgeToEdge);
    await _setOrientations(const <DeviceOrientation>[]);
  }
}
