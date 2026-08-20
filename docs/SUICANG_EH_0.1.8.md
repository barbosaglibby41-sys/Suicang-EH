# Suicang EH 0.1.8

正式版本。

## 更新内容

- 新增外观自由切换：跟随系统、浅色主题、深色主题。
- 主题选择立即生效并在重启后保留。
- 外部漫画卡片完整显示中国时间，精确到秒。
- 修复账户收藏缩略图解析。
- 修复 ExHentai 会话失效被错误显示为空列表的问题。
- ExHentai 自动尝试刷新会话并重试列表请求。
- 优化底部悬浮 Tab 导航间距，移除重复黑色填充。
- 修复小屏空状态溢出。

## 构建

- Android：仅提供 `arm64-v8a` Release APK。
- iOS：提供 LiveContainer 兼容 unsigned IPA。
- 发布门禁：Dart format、Drift codegen、Flutter analyze/test、Android ARM64 Release、iOS Simulator、iOS archive。
