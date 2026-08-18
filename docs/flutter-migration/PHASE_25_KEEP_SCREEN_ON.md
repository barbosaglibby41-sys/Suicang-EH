# Phase 25：KeepScreenOn Platform Adapter

## 原生实现

复用 `taro_web_login_bridge` 的 MethodChannel：

- iOS：`UIApplication.shared.isIdleTimerDisabled = enabled`
- Android：activity window `FLAG_KEEP_SCREEN_ON` add/clear

Dart 将它封装为 `KeepScreenOn` interface + `NativeKeepScreenOn`，Reader 不直接调用 MethodChannel。

## Reader 生命周期

```text
Reader initialize
  -> load ReaderPreferences
  -> sync(readerVisible: true, preference: keepScreenOn)

Reader dispose
  -> KeepScreenOnController.dispose()
  -> setEnabled(false)
```

控制器对相同状态去重，避免每次 build 或状态刷新重复调用 native channel。无论用户偏好为何，Reader 退出都会显式恢复系统默认行为。

## 测试

- visible + preference=true 才开启
- 重复同步不产生重复 native call
- dispose 必定关闭

## 注意

此功能需要 iOS/Android 真机构建验证。Web login plugin 现在包含两个职责（Cookie bridge、screen keep-on）；未来可拆为 platform_core plugin，但当前共享单一受控 MethodChannel，避免宿主工程中分散注册。
