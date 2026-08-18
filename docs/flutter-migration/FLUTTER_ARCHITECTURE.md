# TaroEH Flutter 目标架构与实施蓝图

> 目标：iOS/iPadOS/Android 一套 Dart 代码，保持现有功能并优先重建 Reader、Image Pipeline、Cache、Download。不是 Swift 文件的翻译。

## 1. 技术决策

| 范围 | 选型 | 理由 |
|---|---|---|
| 状态与 DI | `flutter_riverpod` + `riverpod_annotation` | 编译期安全、可测试、按功能隔离；Notifier 只协调 use case |
| 路由 | `go_router` | 声明式深链；shell tabs 与 iPad 自适应路由可复用 |
| HTTP | `dio` + 自定义 `SiteHttpClient` / interceptors | 取消、超时、队列、拦截器、下载流；Cookie 不交给隐式 jar |
| 安全存储 | `flutter_secure_storage` | iOS Keychain / Android EncryptedSharedPreferences 或 Keystore；Cookie 永不进入普通 preferences/Drift |
| 数据库 | `drift` + SQLite（`sqlite3_flutter_libs`） | 强迁移、索引、关系/事务、watch query；比 Isar 更适合收藏/进度/下载/历史的关联查询 |
| 非敏感偏好 | `shared_preferences` | theme、布局、Reader 设置、网络与 cache 偏好 |
| 文件系统 | `path_provider`, `file`, `crypto` | 应用目录、原子写入、可校验磁盘 cache key |
| 图像 decode/render | 自定义 ImagePipeline + Flutter `ImageProvider`/codec API，必要处平台 adapter | 可控 in-flight、内存预算、磁盘 cache、解码尺寸与取消；禁止全交给 `Image.network` |
| Web 登录 | `webview_flutter` + platform cookie bridge | 承载用户登录；提取后规范化至 logical CookieJar |
| 后台下载 | 前台可靠队列先行；`background_downloader` 或原生 URLSession/WorkManager adapter 后接 | iOS/Android 行为不同，必须放在 platform boundary 而非 UI |
| 代码生成 | `freezed`, `json_serializable`, `drift_dev`, `build_runner` | immutable domain state、DTO、schema 保持一致 |
| 测试 | `flutter_test`, `riverpod_test`, `mocktail`, `integration_test` | parser fixture、repository、Notifier、Reader 性能回归 |

依赖版本在建工程时锁定并经过 `flutter pub get` 验证；不要现在猜测版本号写入不可构建的 `pubspec`。

## 2. 目录与依赖规则

```text
lib/
  app/
    app.dart
    bootstrap.dart
    router/app_router.dart
    theme/
    localization/
  core/
    database/
    network/
    storage/
    cache/
    image/
    downloads/
    platform/
    errors/
    logging/
    utils/
  features/
    authentication/{data,domain,presentation}/
    gallery/{data,domain,presentation}/
    home/{data,domain,presentation}/
    search/{data,domain,presentation}/
    tags/{data,domain,presentation}/
    reader/{data,domain,presentation}/
    downloads/{data,domain,presentation}/
    offline/{data,domain,presentation}/
    favorites/{data,domain,presentation}/
    history/{data,domain,presentation}/
    rankings/{data,domain,presentation}/
    settings/{data,domain,presentation}/
  main.dart
```

规则：

1. `presentation → domain → data`；domain 不 import Flutter、Dio、Drift 或 Widget。
2. `data` 实现 domain repository interface；datasource 可依赖 core。
3. Widget 只 dispatch Notifier intent / render immutable state，不能直接请求 HTTP、操作 Drift 或文件。
4. 共享 UI token 置于 `app/theme`；可复用小组件置于 feature 内或 `core`，不用全局 `widgets/` 垃圾场。
5. provider 用构造函数注入；禁止业务 singleton。唯一 app 生命周期资源由 provider keepAlive 管理。

## 3. 模块映射

| Swift 模块 | Flutter feature / core | 备注 |
|---|---|---|
| `Models`, `SiteSource`, `SearchConfig` | `features/gallery/domain`, `features/search/domain` | 拆 DTO/entity/database record |
| `SiteClient`, `SiteParser` | `core/network`, `features/gallery/data`, `features/favorites/data` | Dio transport + source adapter + parser fixtures |
| `SessionStore`, `LoginViews`, `AccountViews` | `features/authentication` | SecureCookieStore + CookieJar + webview bridge |
| `TagTranslationStore` | `features/tags` | asset seed、文件更新、内存索引/可选 Drift FTS |
| `GalleryPersistence`, `LibraryStore` | `features/favorites`, `features/history`, `core/database` | Drift migration 与首次 legacy import |
| `DiscoveryStore`, `RankingStore` | `home`, `search`, `rankings` | history/subscriptions/database queries |
| `ImagePipeline`, `ReaderPageImage` | `core/image`, `reader/presentation` | image request key 包含 URL、referer、variant |
| `ImageURLCache` | `reader/data` + Drift | 仅临时 page/image URL、TTL，不保存 Cookie |
| `SharedReaderView`, `OnlineReaderView` | `features/reader` | `MangaReaderEngine` + online/offline PageSource |
| `ReadingStore` | `features/reader`, `history` | debounce + Drift transaction |
| `DownloadService`, `DownloadStore`, `OfflineLibrary` | `core/downloads`, `downloads`, `offline` | queue、file store、background platform adapter |
| `ModernUI`, Discover/Shelf/Ranking UI | `app/theme` + 对应 presentation | 保留信息架构，彻底重做设计系统 |

## 4. Domain interfaces（首批）

```dart
abstract interface class AuthRepository {
  Stream<AuthSession> watchSession();
  Future<void> importCookieHeader(String header);
  Future<void> clearSession();
  Future<CookieHeader> cookieHeaderFor(SiteSource source);
  Future<ValidationResult> validate(SiteSource source);
}

abstract interface class GalleryRepository {
  Future<GalleryPageResult> discover(DiscoverQuery query);
  Future<GalleryPageResult> search(SearchQuery query);
  Future<Gallery> detail(GalleryKey key);
  Future<PageManifest> pageManifest(GalleryKey key);
  Future<ResolvedImage> resolveImage(PageLink pageLink, {bool forceRefresh = false});
}

abstract interface class ReaderProgressRepository {
  Future<ReadingProgress?> get(GalleryKey key);
  Future<void> save(ReadingProgress progress);
}

abstract interface class DownloadRepository {
  Stream<List<DownloadTask>> watchTasks();
  Future<void> enqueue(DownloadRequest request);
  Future<void> pause(DownloadId id);
  Future<void> resume(DownloadId id);
  Future<void> cancel(DownloadId id, {bool deleteFiles = false});
}
```

`CookieHeader` 只在内存与 secure storage 边界出现。任何 log、database row、analytics event、exception string 均必须脱敏。

## 5. 网络与 Cookie 设计

### 5.1 SiteHttpClient

- Dio 实例不使用隐式 persistent cookie plugin 作为真相来源。
- `SecureCookieStore` 保存结构化 cookie：name/value/domain/path/expiry/secure/httpOnly/updatedAt；value 加密，导出日志时为 `[redacted]`。
- `CookieHeaderInterceptor` 根据请求 host 合并 logical jar；显式拒绝 stale/blacklisted `igneous=mystery`。请求头规范集中在 `EhRequestPolicy`：UA、Accept、Accept-Language、Referer。
- Response interceptor 解析 `Set-Cookie`，只更新允许域。401/403 映射到 typed `AccessDenied` / `AuthenticationRequired`。
- `RequestCoalescer<RequestKey, Response>` 只合并可安全合并的 GET；consumer 取消不得取消仍有其他订阅者的共享任务。
- Retry 只用于幂等请求与网络/5xx 短暂故障，采用有上限的指数退避+jitter；403 不盲目重试。
- 页面 HTML cache 与图片 bytes cache 分开，且不能以含 Cookie 的 headers 作为磁盘 key 的明文部分。

### 5.2 ExHentai

将当前经过验证的流程写成 `ExHentaiSessionRefresher`：清除本地与系统 bridge 中 stale igneous → 获取 E-Hentai 首页补齐 `sk/nw/datatags` → 必要 Cookie 逻辑复制到 ExHentai 域 → 请求 ExHentai → 保存新的有效 igneous。以录制 fixture 和 mock HTTP 测试，而不是通过 UI 测。

## 6. Drift 数据库与数据迁移

### 6.1 初版表

- `galleries`：`source + gid` 唯一；元数据、封面 URL、tags JSON、更新时间。
- `library_entries`：gallery FK、isFavorite、lastOpenedAt。
- `reading_progress`：gallery key 唯一、pageIndex/pageCount/updatedAt。
- `download_tasks`：任务状态、优先级、页总数、已完成、错误码、目标目录、created/updated。
- `download_pages`：task FK、page index、原 URL（非敏感临时）、local path、bytes、state/checksum。
- `image_url_cache`：gallery key、page index/page link/resolved URL、expiresAt；禁止保存 Cookie。
- `search_history`、`subscribed_tags`、`tag_database_metadata`。

创建索引：`galleries(source,gid)`、`library_entries(isFavorite,lastOpenedAt)`、`reading_progress(updatedAt)`、`download_tasks(state,createdAt)`、`image_url_cache(expiresAt)`。

### 6.2 从原 iOS App 迁移

Flutter 与 SwiftUI 的 sandbox/bundle identifier 不同，**不能假设 Flutter 能直接读取 SwiftData 或 Keychain**。迁移分两条：

1. **同 bundle / Flutter module 过渡期（推荐）**：原生 iOS bridge 在 Swift 读取 Keychain、SwiftData、UserDefaults，导出一次性加密迁移 envelope 到 App Group 或 Flutter 可读临时文件；Dart 校验 schema/version/checksum，在 Drift transaction 导入后删除文件。Cookie 仅经 native method channel 直接写入 secure storage，绝不落临时 JSON。
2. **独立 Flutter App**：旧 App 增加“导出迁移包”，用户经 share/files 导入。迁移包包括收藏、历史、进度、下载 metadata、非敏感设置、离线文件 manifest；Cookie 必须由用户在 Flutter 中重新登录或手动导入，默认不导出。

每项迁移使用 `migration_journal`：`id, sourceVersion, status, checksum, importedAt`，确保可重试、幂等。先复制再验证 file count/size，最后切换 active path；绝不删除原 Swift 数据。保留 v1/v2 legacy progress key 的映射：`gid → e-hentai:gid`。

## 7. ImagePipeline（高优先级）

### 7.1 分层

`ImageRequest`（URL、referer、auth scope、kind、targetPixels、cachePolicy） → `ImageRequestCoalescer` → `ImageDiskCache` → `ImageTransport` → `ImageDecoder` → `DecodedImageMemoryCache` → renderer。

- **Variant**：cover 480px、list 720px、reader viewport-aware（设备 DPR × 可见 viewport，允许 quality ceiling）；缩放时请求/解码更大 variant，但设置绝对像素上限和内存预算。
- **内存**：LRU，cost = decoded width × height × 4。使用前后台/内存压力事件动态降预算；只保留当前页、邻页及少量 cover。
- **磁盘**：key = SHA-256(normalized URL + referer + variant version)，bytes 原子写、metadata SQLite；TTL/LRU quota 清理。不得储存 Cookie。
- **解码**：在 isolate/codec API 做尺寸受限 decode；不将长图/10000px 原图整体常驻。图片 header 可先读取尺寸，拒绝明显异常 bomb，映射为可恢复错误。
- **并发**：全局 transport semaphore、decode semaphore、Reader 优先级队列。visible > next pages > covers > background prefetch。
- **取消**：Widget 离屏取消 consumer；无 consumer 的低优先级请求可取消。共享同 key 的 visible consumer 不被错误取消。
- **错误**：网络失败有限 retry；CDN URL 失效时通知 `PageSource` 重新解析 page URL，再重试一次新 URL。

### 7.2 验收

- 同一请求 key 并发 20 次，只产生一条 transport 请求。
- 连续阅读 200 页，不随页数线性增长内存。
- 3000/5000/10000px fixture 可显示、缩放与快速返回，不触发 OOM。
- 离线 file 与在线 URL 经同一 pipeline，仅 transport/disk source 不同。

## 8. MangaReaderEngine（高优先级）

### 8.1 独立核心

`MangaReaderEngine` 为纯 Dart state machine（可单测），持有：

- `ReaderSession`：gallery key、mode、direction、spread policy、position、zoom、controls visibility。
- `PageSource` interface：`count/watchCount/resolve(page)/invalidate(page)`。
- `PreloadPlanner`：视窗/速度/方向输入，输出 visible、warm、cold 优先级集合。
- `ProgressWriter`：300ms debounce + app lifecycle/exit flush。

`OnlinePageSource` 解析 manifest 与动态分页，`OfflinePageSource` 读取已下载页面；二者输出同一 `ReaderPageHandle`，绝不维护两套 Reader。

### 8.2 目标模式与交互

- Vertical long strip、Horizontal paging、Single page、Double page、LTR、RTL。
- 单击 controls、双击 focal zoom、双指 zoom/pan、拖拽、slider 跳页、沉浸式、旋转、自动隐藏。
- Flutter renderer 首期可按模式使用 `CustomScrollView` / `PageView`，但 navigation、spread pairing、preload、progress 都由 engine 驱动。
- 双页必须有 cover/page parity rule；RTL 只改变阅读顺序与 page controller index mapping，不复制 renderer。
- Hero 仅用于封面→reader 入口；进入后不能把全尺寸图绑定在 Hero tree。

### 8.3 性能策略

- reader subtree 使用细粒度 provider/select，页码变更不 rebuild 全部控制栏和页面。
- vertical 使用 sliver lazy build；横向只保留有限邻页。
- 不通过每帧 `LayoutBuilder`/scroll offset 全树广播保存进度；使用页面可见性 + 节流。
- 建立 profile 模式：frame timings、cache hit/miss、decode duration、in-flight 数只在 debug log 中脱敏记录。

## 9. DownloadManager / Offline

- Drift 是队列 source of truth；文件目录为 `ApplicationSupport/offline/<source>_<gid>/`，页名固定零补齐。
- Scheduler 仅管理作品并发；worker 内页级可配置小并发，但按站点限流且按文件事务写入。
- 断点恢复通过 `download_pages` 和临时 `.part` 文件；完成后 atomic rename。
- Pause/Cancel 取消 token；Retry 保留错误分类、避免无限循环；磁盘空间阈值检查后再 enqueue。
- 第一阶段：前台/应用存活期间可靠恢复 + 冷启动重新排队。第二阶段：`BackgroundDownloadAdapter` 接 iOS URLSession background / Android WorkManager，能力标为 platform-specific，不伪称跨端一致。
- Offline library 从 DB manifest 展示，定期 reconcile 文件存在性；删除以 transaction 标记后删文件，失败可恢复清理。

## 10. UI 重设计

### Design system

`app/theme` 定义 semantic token，不输出默认 Material demo：

- `TaroColorScheme`：ink/canvas/surface/elevated/line/accent/status，亮暗分别设计。
- `TaroTypography`：编辑感标题、清晰正文、紧凑 metadata；遵循系统 Dynamic Type。
- 4pt/8pt spacing scale、连续圆角只用于 cover/card、轻阴影/边线、统一 motion（120/180/260ms）。
- Cupertino 交互质感优先 iOS/iPad，Material 3 adaptive primitives 用于 Android；业务视觉组件一致。

### 信息架构

- iPhone：发现、书架、下载、设置 shell tabs；搜索可作为 overlay/route。
- iPad：`NavigationSplitView` 等价的 adaptive rail + list + detail；Reader 全屏。
- Home：搜索、继续阅读 hero、横向内容轨道、最近/收藏/推荐/热门/随机；避免九宫格。
- Gallery detail：沉浸封面、清晰 title/meta/score、进度、主阅读按钮、收藏/下载次级操作、可折叠 tags，cover→reader Hero。
- Search：即时 tag suggestion、中文显示、原始 query 可见、history；筛选放入结构化 bottom sheet。
- Download：封面、进度、速率/剩余时间（仅能准确计算时显示）、状态与行内操作。

## 11. 分阶段实施计划与门禁

| 阶段 | 交付 | 完成门禁 |
|---|---|---|
| 0 分析（完成） | `SWIFT_ARCHITECTURE.md`、本报告 | 以 release HEAD 为审计源，列出 parity |
| 1 工程骨架 | Flutter app、lint、Riverpod、GoRouter、theme、CI | `flutter analyze`、widget smoke test；不删除 Swift |
| 2 domain/database | entities、repository contracts、Drift schema v1/migrations | DAO tests、migration tests、无 Widget 直连 DB |
| 3 auth/network | secure CookieJar、Dio policy、HTML parser fixtures、web login bridge | cookie 脱敏 tests；403/igneous fixture tests |
| 4 gallery/search/tags | 首页、详情、搜索、排行榜、标签库、收藏/历史 | API parser fixture + repository/notifier tests |
| 5 image pipeline | memory/disk/coalescing/decode/prefetch | concurrency、large image、memory budget test |
| 6 reader | engine、online/offline PageSource、核心 6 模式 | progress/parity/perf integration tests |
| 7 downloads/offline | queue、recovery、file manifest、offline reader | pause/resume/restart/reconcile test |
| 8 adaptive UI | iPhone/iPad/Android layouts、accessibility、motion | golden/widget tests at phone/tablet sizes |
| 9 migration/release | native export bridge、import journal、telemetry-free diagnostics | fresh install + upgrade dry run + rollback validation |
| 10 parity cutover | feature matrix、beta、performance profiling | Swift kept until all P0/P1 parity passes |

每阶段固定流程：设计 review → 小批实现 → format/analyze/test → architecture review → GitHub Actions 构建 artifact。iSH 不承担 iOS 编译，按照既有偏好由 GitHub Actions 运行 Flutter analyze/test/build。

## 12. 初始测试矩阵

- Unit：cookie parser/merge、HTML parser、query translation、page ordering/spread rules、LRU/coalescer、download state machine。
- DAO：Drift upgrade、唯一键、TTL cleanup、migration journal idempotency。
- Notifier：loading/error/cancel/retry、source switch、auth clear。
- Widget/golden：亮暗、窄手机、横屏、iPad 11/13 英寸、字体放大。
- Integration：mock server 在线阅读（URL 过期重解析）、下载→离线→Reader、Cookie refresh flow。
- Performance：profile device 上首屏、长画廊 200+ 页、快速翻页、10k px fixture；记录 p50/p95 frame timing 和 RSS，不以“看起来顺”验收。

## 13. 明确非目标（首阶段）

- 不自动转移旧 Keychain Cookie 到独立 bundle。
- 不承诺 iOS/Android 背景下载完全一致。
- 不在没有 fixture 与协议测试时重写站点解析。
- 不删除 SwiftUI/SwiftData 数据或原工程，直到功能矩阵与迁移回滚验收完成。
