# Phase 10：Download Hardening

## 本阶段完成

- 每个 active task 维护 `Dio CancelToken`。
  - `pause` 和 `cancel` 会立即取消当前 HTTP 请求。
  - 取消被识别为用户动作，不会覆盖为 `failed`。
  - worker finally 清理 token，避免过期 worker 干扰之后 resume/retry。
- 每页开始下载前，先把 target localPath 与 `downloading` 写入 Drift。
- 冷启动恢复：
  - task `downloading -> queued`。
  - page `queued/downloading` 检查已有 localPath；文件已落盘则恢复为 completed 并重新聚合 task progress。
  - Worker 启动前删除同一 gallery 的残留 `.part` 文件。
- 下载文件路径与临时文件处理维持在 `DownloadFileStore`，不泄漏到 Widget。

## 未实现：磁盘空间能力

Flutter/Dart 没有可靠且跨 iOS/Android 的免费磁盘空间 API。没有提交一个永远允许下载的假检查。后续通过 `DiskSpacePlatformAdapter`：

- iOS：FileManager/URLResourceValues native channel。
- Android：StatFs native channel。
- 只在适配器真实可用时，按 reserve threshold + 基于历史大小/Content-Length 的 estimate 阻止入队。

## 已知平台边界

此队列在应用存活期间可靠；系统挂起/终止后冷启动恢复，但尚不是 iOS background URLSession 或 Android WorkManager。平台后台 adapter 必须单独实现并如实在 UI 中标注能力。

## 下一步

优先实现 Tags Translation 与 Search suggestions，补齐中文标签能力；随后进行 Adaptive UI、收藏/历史和 Cloud Favorites feature parity。
