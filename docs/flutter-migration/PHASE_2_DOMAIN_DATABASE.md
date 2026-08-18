# Phase 2：Domain 与 Drift 数据库 V1

## 范围

本阶段建立 Flutter 领域模型、Repository 契约和 Drift schema v1；未连接真实 HTTP、Cookie、WebView 或下载 worker。这样可以先验证数据边界，不会把 Swift 的 `ObservableObject` / `UserDefaults` 实现迁入 Widget。

## 已建立的领域对象

- `GalleryKey`：由 `SiteSource + gid` 构成，稳定键为 `e-hentai:<gid>` / `exhentai:<gid>`，避免跨站 gid 冲突。
- `Gallery` / `GalleryTag`：独立于 Drift 和 Flutter。
- `ReadingProgress`、`DownloadTask` / `DownloadStatus`：独立于持久化、网络与 UI。
- `GalleryRepository`、`LibraryRepository`、`ReadingProgressRepository`、`DownloadRepository`：只描述 domain intent，不 import Dio、Drift 或 Widgets。

## Drift schema v1

`AppDatabase` 以 SQLite 保存下列非敏感数据：

- `galleries`、`library_entries`、`reading_progress_entries`
- `download_tasks`、`download_pages`
- `image_url_cache_entries`（只保存临时 URL 与 TTL，绝不保存 Cookie）
- `search_history_entries`、`subscribed_tags`、`tag_database_metadata`
- `migration_journal`（一次性原生数据导入的幂等性记录）

所有 Gallery 关联表均使用 `(source, gid)` 复合主键；下载页以 `(taskId, pageIndex)` 唯一。`beforeOpen` 开启 SQLite foreign key enforcement。

## 当前实现

- `DriftLibraryRepository` 已实现本地收藏、历史流、记录打开和清除历史；每次写入将 Gallery 与 library entry 放入同一个 transaction。
- `AppDatabase.open()` 在 Application Support 下创建 `taro_eh.sqlite`；测试通过 `NativeDatabase.memory()` 注入，不接触设备文件系统。
- CI 在 analyze/test 与 Android build 前运行 `build_runner` 生成 `app_database.g.dart`。

## 迁移规则

- schema version 固定为 `1`。升级分支暂时显式抛错，避免在没有设计 migration 的情况下静默损坏数据；每次将版本提升到 `N+1` 时必须新增、测试 `from → to` 迁移。
- `migration_journal` 将用于后续 Swift bridge / 手动导入包：校验 checksum，transaction 导入，成功后写入 journal；不会删除原 Swift 数据。
- Cookie 不进入 Drift，也不进入 migration package 默认内容；认证阶段使用 secure storage。

## 验收

- domain unit tests：稳定 key、跨 source 隔离、Tag parser。
- database tests：`(source,gid)` 唯一性及跨 source 同 gid 共存。
- 后续 CI 运行：`dart run build_runner build --delete-conflicting-outputs` → format → analyze → test。

## 下一阶段

接入 `flutter_secure_storage`、显式 CookieJar、Dio `SiteHttpClient`、typed network errors 与 HTML fixture parser。UI 仍不得直接依赖这些 data source。
