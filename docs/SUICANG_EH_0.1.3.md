# Suicang EH 0.1.3

正式版本。

## 更新内容

- 漫画卡片统一显示分类、页数和相对发布时间。
- 详情页信息区改为低对比细边框网格布局。
- 详情页发布时间显示到秒级相对时间，并保留完整时间 Tooltip。
- Reader 进入后隐藏系统状态栏和导航栏，实现沉浸式全屏。
- 关注页进入后自动请求所有关注作者/发布者的最新搜索结果。
- 底部功能页采用稳定 IndexedStack Shell，减少页面切换画面残留。
- 中文标签翻译、补全、详情标签分组和点击搜索继续保留。

## 构建

- Android：仅提供 arm64-v8a Release APK。
- iOS：提供 LiveContainer 兼容 unsigned IPA。
- 验收：Dart/Drift/Flutter analyze/test、Android ARM64、iOS Simulator、iOS archive。
