# Phase 9：DownloadManager 队列与离线文件写入

## 状态机

`DownloadTask` 的持久化状态：

```text
queued -> downloading -> completed
  ^          |    |
  |          |    +-> failed -> queued (retry)
  |          +-> paused -> queued (resume)
  +---------------------- cancelled
```

Drift 的 `download_tasks` / `download_pages` 是唯一事实来源。worker、UI 和 Offline Library 都不维护自己的任务副本。

## 已实现

- `DownloadRequest`：Gallery + page manifest 入队。
- `DriftDownloadRepository`：
  - 入队时 transaction 写 Gallery、task 和 page rows。
  - 最大两个 gallery task 并发；单个 gallery 内页面顺序下载，避免对站点的突发并发。
  - 每页先由 GalleryRepository 从 page URL 解析真实 image URL，再通过 SiteHttpClient（显式 Cookie）下载。
  - 文件写入 `Application Support/offline/<source>/<gid>/0001.ext`。
  - 使用 `.part` + atomic rename；成功后才将 DownloadPage 标为 `completed` 并更新 task completedPages。
  - pause/resume/retry/cancel；应用重启时 `downloading -> queued` 后重新调度。
- Download queue UI：状态、进度、暂停、继续、重试、取消/删除。
- Gallery Detail “下载”操作会先取得完整 page manifest，再实际入队。
- Offline Library 已消费 completed task + page local paths，形成 Online → Download → Offline → same Reader 链路。

## 已知限制与后续

- 当前 pause 是 cooperative：正在进行的单页网络请求可结束，下一页开始前读取 DB 状态后停止。后续可为每个 worker 维护 CancelToken，实现即时中断。
- 不计算不可靠的下载速度/剩余时间；等 streaming transport 与移动平均实现后再显示。
- 没有 iOS background URLSession / Android WorkManager。这必须通过 platform adapter 逐平台实现，不能用前台 Future 冒充背景下载。
- 未做磁盘空间预检查和 orphan reconcile；下一轮 Download hardening 加入。

## 测试

本阶段包含 DownloadTask 进度零分母保护测试。Repository 的 transport/file integration 测试需要通过可注入 fake FileStore / SiteHttpClient 完成，将在 Download hardening 阶段与即时 cancellation 一起加入。
