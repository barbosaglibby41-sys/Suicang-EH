# Suicang EH

跨平台 E-Hentai / ExHentai 漫画阅读器，面向 iOS、Android 和桌面端的现代化阅读体验。

Suicang EH 将搜索、标签翻译、作品收藏、账户云收藏、作者关注、离线下载和沉浸式 Reader 整合在一个统一应用中。

## 主要功能

### 发现与搜索

- E-Hentai / ExHentai 来源切换
- 最新、热门、随机和排行榜
- 排行榜周期与分页
- 标题、作者、标签搜索
- 中文标签补全
- 标签翻译库在线更新
- 点击标签直接搜索原始英文标签
- 搜索历史持久化

### 作品详情

- 作品封面、页数、语言、文件大小、评分、收藏次数
- 秒级相对发布时间，例如“42 秒前”“3 小时 12 分钟前”
- 标签中文翻译与英文回退
- 标签订阅
- 评论阅读、发布、顶/踩
- 内容预览 Sprite Strip
- 预览页点击跳转 Reader
- Torrent 外部打开
- 本地收藏与账户云收藏分离

### 关注

- 关注作者
- 关注发布者
- 关注页进入后自动检查最新搜索结果
- 按发布时间显示关注源的新作品
- 本地关注数据，不依赖账户权限

### Reader

- 横向分页与纵向长条
- LTR / RTL 阅读方向
- Contain / Cover 页面适配
- 双击缩放、手势缩放
- Slider 跳页
- 在线阅读与离线阅读共用 Reader Engine
- 动图与视频基础播放
- 沉浸式全屏
- Reader 偏好与阅读进度持久化
- 可见页优先解码与邻页预加载
- iOS / Android 阅读时保持屏幕常亮

### 离线与迁移

- 顺序下载、暂停、恢复、取消、重试
- `.part` 临时文件与原子重命名
- 冷启动下载恢复
- Offline Library
- 非敏感迁移包导入
- 收藏、历史、阅读进度迁移
- 不迁移 Cookie、Keychain、Token、密码或 API Key

## 下载

最新正式版本请前往：

[Suicang EH Releases](https://github.com/barbosaglibby41-sys/Suicang-EH/releases)

Android 正式包仅提供 `arm64-v8a` ABI。

iOS 提供 unsigned IPA，安装前需要通过 LiveContainer、SideStore、AltStore、Sideloadly 或 Xcode 进行签名/侧载。

## 架构

```text
Flutter + Riverpod + GoRouter + Drift

Feature-first Clean Architecture
├── data
├── domain
└── presentation
```

核心基础设施：

- Secure CookieJar
- Cookie-aware SiteHttpClient
- Request Coalescing + Safe Retry
- ImagePipeline Memory/Disk Cache
- Targeted Image Decode
- Download Queue
- Drift Schema Migration
- Native iOS/Android bridges

## 开发

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

GitHub Actions 会验证：

- Dart format
- Drift code generation
- Flutter analyze
- Flutter tests
- Android ARM64 Release APK
- iOS Simulator build

## 许可证与第三方数据

Suicang EH 的代码许可证和第三方数据许可证请以仓库中的 LICENSE / NOTICE 文件为准。

EhTagTranslation 数据库遵循其原始许可和署名要求，更新后的标签数据库不会改变原始数据许可证。

## 贡献

欢迎提交 Issue 和 Pull Request：

- 请先说明复现步骤或设计目标。
- 网络协议改动需要匿名 fixture 或公开协议依据。
- 不要提交 Cookie、Keychain 导出、Token、密码、API Key 或私人数据。
- 新功能应补充单元测试、Widget 测试或 parser fixture。
