# Suicang EH 0.1.7

正式版本。

## 更新内容

- 账户收藏列表修复缩略图不显示问题，兼容 `src`、`data-src` 和 `data-lazy-src`。
- 底部 Tab 改为半透明悬浮胶囊导航，减少暗色主题下的大块黑色区域。
- 详情页作者和发布者支持点击搜索。
- 长按作者/发布者可以关注。
- 详情页作者、发布者、分类、页数、完整发布时间统一展示。
- 发布时间显示中国时间，精确到秒。
- 保留详情页横向统计条和紧凑操作栏。
- 保留 ExHentai 会话失效识别与自动刷新重试。

## 构建

- Android：仅提供 `arm64-v8a` Release APK。
- iOS：提供 LiveContainer 兼容 unsigned IPA。
- 发布门禁：Dart format、Drift codegen、Flutter analyze/test、Android ARM64 Release、iOS Simulator、iOS archive。
