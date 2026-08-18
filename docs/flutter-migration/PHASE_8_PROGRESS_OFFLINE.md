# Phase 8：Reading Progress 与 Offline Library

## 阅读进度

`DriftReadingProgressRepository` 实现 `ReadingProgressRepository`：

- 使用 `(source, gid)` 作为唯一键；同 gid 的 E-Hentai / ExHentai 进度绝不会相互覆盖。
- Reader Engine 继续负责 300ms debounce 与退出 flush。
- Engine provider 的 `onProgress` 将最终位置、真实 page count 与 UTC 时间写入 Drift。
- Reader 创建前读取已保存进度，将 `initialIndex` 注入同一个 Engine；页面总数加载后 Engine 会自动 clamp，旧进度不会使 Reader 越界。

## 离线书库

`OfflineLibraryRepository` 以 Drift 中 `download_tasks(status=completed)`、`download_pages` 和 `galleries` 为 source of truth：

- 完成下载的任务按更新时间流式展示。
- 同一下载任务的 local page paths 和 byte count 聚合为 `OfflineGallery`。
- 离线阅读通过 `OfflinePageSource(File list)` 注入**同一个** `ReaderScreen`，不复制 Reader UI 或进度逻辑。
- 删除离线副本先删除 download metadata transaction，再尽力删除页面文件；文件删除失败保留为可后续 reconcile 的 orphan，不阻塞用户操作。

## 当前产品边界

离线书库已能读取未来 DownloadManager 写入的 DB/file manifest，但 DownloadManager 目前尚未实现，因此初始书库会是空的。这是有意的：不再从 UI 伪造下载状态，也不读取随机目录作为数据源。

## 后续下载阶段

1. DownloadRepository 与 queue state machine。
2. task/page records、目标目录、`.part` 原子写入。
3. pause/resume/retry/cancel 与启动恢复。
4. 磁盘空间检查、file reconcile、平台 background adapter。

这会让 Online → Download → OfflineLibrary → OfflinePageSource → Reader 形成单一数据链。
