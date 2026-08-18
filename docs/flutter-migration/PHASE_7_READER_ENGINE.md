# Phase 7：Reader Engine 与统一 Online/Offline Reader

## 核心设计

`MangaReaderEngine` 是纯 Dart 状态机，Widget 只负责渲染和手势转发。它管理：

- `ReaderState`：horizontal/vertical、LTR/RTL、contain/cover、当前位置、页数、控制栏、zoom。
- `PageSource`：`pageCount`、`pageAt`、`invalidate`。
- 进度 debounce：翻页后 300ms 回调，dispose 时 flush。
- 页面边界 clamp，避免跳到负数或超过最后一页。
- 当前页周围 preload request stream。

## Online / Offline 共用路径

- `OnlinePageSource`：从 GalleryRepository 拉取 manifest，再按页解析真实图片 URL；失效时 invalidate 并 force refresh。
- `OfflinePageSource`：从本地 File 列表输出 `Uri.file`，不复制 Reader 逻辑。
- 两者都输出同一个 `ReaderPage`，通过同一个 `ImagePipeline` 交给 renderer。

## 当前 UI

- `/reader/:source/:gid` 位于 ShellRoute 之外，作为独立全屏页面。
- 横向分页：`PageView`，支持 RTL 映射。
- 纵向长条：`ListView`。
- `InteractiveViewer` 支持缩放与拖拽。
- 单击/双击切换控制栏。
- 控制栏提供关闭、横向/纵向切换、contain/cover、页码和进度。
- 详情页“开始阅读”已连接 Reader route。

## 已知下一步

本阶段 Reader UI 是可工作的骨架，但还没有完成：

- 稳定 `PageController` 状态恢复和 Slider 跳页。
- 真正的双页 spread、横竖屏策略和细粒度可见性进度。
- ImagePipeline 的 targetPixels codec 解码与 Reader 优先级 prefetch。
- ReadingProgressRepository 接入 Drift，当前 `onProgress` 仍由调用方注入。
- 离线下载记录对接 OfflinePageSource 的自动文件发现。

这些问题被保留为明确的 Reader hardening 工作，不伪称已经达到原生最终性能。

## 测试

- Engine 初始化页数、边界 clamp 和邻页预加载。
- 当前页 retry 前调用 PageSource.invalidate。

下一阶段优先完成 ReadingProgressRepository、在线/离线进度恢复和 DownloadManager 基础，然后再做 Reader 性能 hardening。
