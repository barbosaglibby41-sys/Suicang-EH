# Suicang EH 0.1.5

正式版本。

## 本次更新

### Gallery Detail 2.0

- 详情页改为 Suicang 极简黑曜石 UI。
- 封面居中展示，标题与作品摘要层级重新设计。
- 统计信息改为横向滑动条：语言、页数、发布时间、大小、收藏、评分。
- 主操作突出“开始阅读”。
- 收藏、下载、云收藏、关注收紧为图标操作栏。
- 减少大面积卡片空白和重复操作按钮。

### 随机探索

- 随机批次从 12 提升到 18。
- 每批最多探测 16 个随机游标。
- 当前随机会话按 GalleryKey 去重。
- 滚动到底继续请求新随机批次。
- 新增随机轮次、已发现数量和空批次耗尽保护。
- “换一批”和下拉刷新会创建新的随机会话。

### 书架与关注

- 书架加入独立“关注”页面。
- 进入关注页后自动检查关注作者/发布者的新作品。
- 保留本地收藏、历史、账户收藏的独立数据边界。

### 时间显示

- 外部卡片显示相对发布时间或中国时间。
- 详情页 Tooltip 显示完整中国时间。
- 绝对时间统一使用 UTC+8。

## 构建

- Android：仅提供 `arm64-v8a` Release APK。
- iOS：提供 LiveContainer 兼容 unsigned IPA。
- 自检：Dart format、Drift codegen、Flutter analyze/test、Android ARM64 Release、iOS Simulator、iOS archive。
