# Suicang EH 0.1.6

正式版本。

## 更新内容

- Reader 专用沉浸式全屏 Shell。
- 进入 Reader 隐藏状态栏和系统导航栏。
- Reader 内容移除外层 SafeArea，避免顶部重叠和底部黑色填充。
- Reader 控制栏局部使用 SafeArea，避免刘海和 Home Indicator 遮挡。
- 退出 Reader 恢复 Suicang edge-to-edge 系统 UI 基线。
- 进入/退出全屏状态具有重复调用保护。
- 增加 Reader 全屏生命周期测试。
- 保留详情页 2.0 UI、随机探索、关注页、标签翻译和搜索交互更新。

## 构建

- Android：仅提供 arm64-v8a Release APK。
- iOS：提供 LiveContainer 兼容 unsigned IPA。
- 发布门禁：Dart format、Drift codegen、Flutter analyze/test、Android ARM64 Release、iOS Simulator、iOS archive。
