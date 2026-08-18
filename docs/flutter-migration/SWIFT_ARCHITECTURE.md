# TaroEH Swift 架构审计

> 审计基线：`release-repo` 的 `master`，HEAD `8b8043f`（2026-08-19）。本报告以当前可发布仓库的 47 个 Swift 文件、约 6,347 行 Swift 为准；不以旁边未提交的 `TaroEH/` 工作目录为迁移基线。

## 1. 工程与运行边界

- iOS 17+，SwiftUI，`TARGETED_DEVICE_FAMILY=1,2`；没有 Android/macOS 工程。
- XcodeGen `project.yml` 管理工程；`Info.plist` 支持手机横竖屏与 iPad。
- 依赖全为 Apple 框架：SwiftUI、Foundation、UIKit、SwiftData、WebKit、Security、ImageIO、Combine；目前没有 SPM/CocoaPods。
- 直接 HTTPS 连接目标站点；不使用项目中转服务。Cookie 应仅保存在本机 Keychain。
- 仓库当前还有未提交的 `.github/workflows/diagnose-xcode.yml` 修改；迁移提交不得混入该文件。

## 2. 当前分层实际情况

当前实现不是严格分层：View、状态、持久化与站点调用在若干文件内混合。但可以辨识下列子系统。

| 子系统 | 主要文件 | 当前职责 | 主要耦合/风险 |
|---|---|---|---|
| 应用组合 | `TaroEHApp.swift`, `ContentView.swift` | 创建 SwiftData container、EnvironmentObject、四 Tab 与导航 | Composition Root 未独立；根视图承担路由与注入 |
| 领域模型 | `Models.swift`, `SiteSource.swift`, `SearchConfig.swift` | Gallery、Tag、页面、来源、错误、搜索筛选 | `Gallery` 同时是网络 DTO、持久化对象和 UI 模型 |
| 站点通信 | `SiteClient.swift`, `SiteParser.swift` | 请求头、Cookie 合并、首页/搜索/详情/排行榜/云收藏/图片 URL/评论/种子 | HTML 正则解析、请求和业务协议集中于 singleton |
| 身份与 Cookie | `SessionStore.swift`, `LoginViews.swift`, `AccountViews.swift` | WKWebView 登录、Cookie 导入/验证/清除、Keychain、ExHentai `igneous` 刷新 | 强依赖 `HTTPCookieStorage`；Cookie 与站点协议需精确复现 |
| 标签 | `TagTranslationStore.swift`, `Resources/tag_translation_seed.json` | 内置/远端标签库、中文转查询、补全、显示偏好 | 常驻内存索引；查询算法为线性 fallback |
| 本地书库 | `GalleryPersistence.swift`, `LibraryStore.swift`, `DiscoveryStore.swift` | SwiftData 收藏/历史，UserDefaults 兼容回退；搜索历史、订阅标签 | UserDefaults、SwiftData 双写且读取路径分散 |
| 阅读进度与 URL 缓存 | `ReadingStore.swift`, `ImageURLCache.swift` | 进度、下载任务、临时图片 URL、写入合并 | JSON 整体读写，后续规模增长会变慢 |
| 图片 | `ImagePipeline.swift`, `ReaderPageImage.swift` | URLSession、内存 NSCache、in-flight 去重、解码缩放、预取 | 无自管磁盘 bitmap 缓存；阅读页同样被下采样至 1200px |
| Reader | `SharedReaderView.swift`, `OnlineReaderView.swift`, `DownloadsView.swift` | 在线/离线统一容器、横向/纵向、缩放、自动隐藏、目录分页、预取 | 仅 horizontal/vertical 两模式；TabView/LazyVStack 承担核心引擎 |
| 下载/离线 | `DownloadService.swift`, `ReadingStore.swift`, `OfflineLibrary.swift` | 并发作品调度、顺序页下载、暂停/重试、沙盒离线文件 | 非 iOS 后台 URLSession；任务 metadata 存 UserDefaults |
| 展示设计 | `ModernUI.swift`, `DiscoverUI.swift`, `ShelfUI.swift`, `GalleryListStyle.swift`, `TagStyle.swift`, `Haptics.swift` 等 | 现代卡片、发现/书架/排行榜、详情、评论、预览 | 视觉 token 仍是 Swift View 内静态值，UI 与流程 View 有较大文件 |

## 3. 关键数据流

### 3.1 在线作品

`DiscoverView / Ranking / CloudFavorites` → `SiteClient` → `SiteParser` → `Gallery` → `GalleryDetailView`。详情页先用 `detailMetadata`，进入 Reader 后 `OnlineReaderView` 取得/缓存 `pageLinks`，再逐页解析真实图片 URL，交给 `ImagePipeline` 请求与解码。`ReadingStore` 合并写入阅读位置。

### 3.2 鉴权

`WKWebView` 或粘贴 Cookie → `SessionStore` 规范化、Keychain 写入、安装到系统 Cookie 存储 → `SiteClient.applyHeaders` 以逻辑 Cookie jar 为主、系统存储为回退。ExHentai 刷新会清除 stale `igneous`，访问 E-Hentai 以取得辅助 Cookie，克隆必要字段后再请求 ExHentai 并持久化有效 `igneous`。

### 3.3 下载与离线

详情页解析所有图片 URL → `DownloadStore.enqueue` → 作品级并发 scheduler → `DownloadService` 页级顺序写入 `Application Support/Offline/<source>_<gid>/0001.ext` → `OfflineLibrary` 扫描同一文件夹 → `OfflineReaderView` 使用 `SharedReaderView`。

## 4. 已具备能力（迁移 parity 清单）

1. E-Hentai / ExHentai、可配置基础地址、首页/最新/热门/随机、搜索游标与排行榜。
2. HTML 解析：画廊、详情、标签、页链接、图片真实地址、评论、预览雪碧图、收藏夹、种子。
3. Web 登录、Cookie 文本导入、Cookie 状态/验证、Keychain、跨 e-hentai/exhentai Cookie 策略与 igneous 刷新。
4. 本地收藏、历史、站点云收藏（10 文件夹、分页、写回）；SwiftData + 旧 UserDefaults 迁移。
5. 中文标签库、补全、中文查询转换、远程升级、内置回退。
6. 在线/离线阅读、横向分页与纵向长条、双击缩放、阅读进度、控制栏自动隐藏、预加载、URL 过期重解析。
7. 下载队列、暂停/恢复/重试/删除、并发限制、Wi-Fi 偏好、文件占用统计。
8. Light/Dark、iPhone/iPad、现代发现/书架/详情/排行榜界面、触觉反馈。

## 5. 迁移时不能照抄的实现

- `ObservableObject` + `EnvironmentObject` 不迁移为全局 Riverpod；应改为 feature scoped providers 与依赖注入。
- `Gallery` 不继续同时充当 HTML DTO、数据库行与展示模型；分为 DTO、domain entity、Drift companion/record。
- SwiftData/UserDefaults 双写不直接复制；Flutter 首次启动只执行一次、有版本与校验的导入。
- `URLSession`/`HTTPCookieStorage` 行为不假设 Dio 自动等价；需要一个显式、加密持久化的 logical CookieJar。
- 当前图片管线的 1200px 固定下采样不适用于可缩放原图阅读，应按 cover/thumbnail/reader 三类 decode target 分策略。
- `SharedReaderView` 不能直接翻为 `PageView + Image.network`；Reader 必须是独立 engine 与 renderer 协作。

## 6. 已识别的技术债与迁移决策

| 现状 | 决策 |
|---|---|
| 正则解析依赖站点结构 | 保留协议测试 fixture，解析器封装在 datasource；增加 HTML contract tests 与失败可诊断性 |
| 单例 `SiteClient`/`ImagePipeline`/Store | 用 Riverpod provider scope、接口与 composition root 替代 |
| 内存缓存用 JPEG 重编码估算 cost | 使用 decoded pixel bytes（width × height × 4）与 LRU 预算 |
| URL 缓存与下载任务 JSON 整体写 | Drift 表级更新、索引和事务 |
| 下载不是真后台恢复 | 第一阶段实现前台可靠恢复；iOS/Android 后台下载作为平台 adapter 的明确后续能力 |
| Reader 不支持 RTL、单双页 | 目标 Engine 覆盖模式；先用同一 page source 验证 online/offline parity |

## 7. 文件依赖概览

- `ContentView` 依赖几乎所有 presentation store；是现有最大耦合点。
- `SiteClient` 依赖 `SiteParser`、`SessionStore/Keychain` 语义、网络配置；是站点协议边界。
- `OnlineReaderView` 依赖 `SiteClient`、`ImageURLCache`、`ImagePipeline`、`SharedReaderView`、`ReadingStore`。
- `DownloadStore` 依赖 `DownloadService`、`OfflineLibrary`、`Gallery`、设置值。
- `LibraryStore` 依赖 `GalleryRecord`/SwiftData 并回退到 UserDefaults。

Flutter 将把这些依赖方向反转为 domain interface 指向内层，Dio/Drift/secure storage 位于 data 实现层。