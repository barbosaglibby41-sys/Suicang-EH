# Phase 16：Platform Host 与 CI 验证

## CI 矩阵

Flutter CI 现在包含：

1. `analyze-and-test`（Ubuntu）：pub get、Drift build_runner、format、analyze、test。
2. `android-debug`（Ubuntu）：必要时生成 Android host、debug APK build、artifact。
3. `ios-simulator`（macOS 15）：必要时生成 iOS host、CocoaPods、simulator build、失败时诊断 artifact。

plugin、assets、platform host 路径现在会触发 CI，原生 bridge 改动不会被 Dart-only CI 漏掉。

## 宿主生成策略

iSH 环境未安装 Flutter SDK 且可用 rootfs 空间不足以安全安装完整 SDK。因此不在手机 shell 临时生成 iOS/Android scaffold。CI 在 host 目录不存在时运行：

```sh
flutter create --platforms=android --project-name=taro_eh_flutter .
flutter create --platforms=ios --project-name=taro_eh_flutter .
```

首次 Actions 成功后应把生成的 `ios/` 和 `android/` 目录审查并提交，之后改为只验证已提交 host，避免平台配置在每次 CI 中漂移。

## 原生插件构建修正

- 添加 plugin MIT LICENSE，CocoaPods podspec 的 license file 可被解析。
- Android bridge 去除 AppCompat 依赖，并使用 API 23 兼容的 UTC 时间格式。
- iOS bridge 将可选 expiresAt 规范化为 `NSNull()`，避免 Flutter channel 中 optional Any 转换错误。

## 验收

需要在 GitHub Actions 上实际验证：

- Dart format/analyze/test
- Drift `.g.dart` codegen
- Android Kotlin plugin compile + debug APK
- iOS Swift plugin compile + pod install + simulator app build

尚未完成的真机验收：WebView login、HttpOnly Cookie capture、ExHentai refresh、Cloud Favorites POST。
