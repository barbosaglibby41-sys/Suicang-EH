# Suicang EH 0.1.2

## 新增与改进

- 作品详情：紧凑信息网格、发布时间相对时间（秒/分钟/小时）、完整绝对时间提示。
- 详情标签：中文翻译显示、无翻译英文回退、点击标签搜索、长按订阅。
- 标签翻译数据库：查看版本、在线更新、失败回退、恢复内置版本。
- 搜索补全：中文输入建议显示中文名与 `namespace : key`，点击替换为精确英文标签。
- 书架：本地收藏 / 历史 / 账户收藏三页；收藏时间 / 发布时间排序与日期筛选。
- 关注：关注作者或发布者，并在关注页手动刷新获取新作品。
- 网络：ExHentai 详情可优先重定向到 E-Hentai 表站，失败自动回退。
- Reader：媒体类型识别、动态图/视频基础渲染、目标尺寸解码、解码优先级调度、预览跳转指定页。
- UI：底部 Tab 改用 StatefulShell indexed stack，修复功能页切换残影；补充基础无障碍语义。
- 品牌：统一为 Suicang EH，应用图标使用 Suicang EH 视觉资产。

## 构建

- Android：仅提供 `arm64-v8a` Release APK。
- iOS：提供 LiveContainer 兼容的 unsigned IPA。
- 发布门禁：Dart format、Drift codegen、Flutter analyze/test、Android ARM64 Release、iOS Simulator build、IPA archive。
