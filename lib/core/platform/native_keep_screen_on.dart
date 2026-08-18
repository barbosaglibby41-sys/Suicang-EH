import 'package:taro_web_login_bridge/taro_web_login_bridge.dart';

import 'keep_screen_on.dart';

class NativeKeepScreenOn implements KeepScreenOn {
  NativeKeepScreenOn({TaroWebLoginBridge? bridge})
      : _bridge = bridge ?? TaroWebLoginBridge();

  final TaroWebLoginBridge _bridge;

  @override
  Future<void> setEnabled(bool enabled) => _bridge.setKeepScreenOn(enabled);
}
