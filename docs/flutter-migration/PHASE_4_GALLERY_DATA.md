# Phase 4：Gallery 数据源、HTML Parser 与 Repository

## 范围

本阶段把 Swift `SiteClient` / `SiteParser` 中画廊列表、搜索、详情、阅读目录与单页图片 URL 的协议迁到 Flutter data layer。没有把网络调用放进 Widget；Home/Search UI 仍待下一 presentation 阶段接入 Notifier。

## 结构

```text
presentation provider
  -> GalleryRepository (domain contract)
    -> EhGalleryRepository (data)
      -> SiteHttpClient (Dio + logical CookieJar)
      -> EhHtmlParser (pure Dart, fixture tested)
      -> Drift galleries cache
```

## Domain additions

- `GalleryPageResult`：列表与服务端 `next` cursor。
- `GallerySearchQuery`：source、keyword、tags、cursor；组装站点查询文本。
- `GalleryDetail`：metadata + 可选 page manifest。
- `GalleryRepository`：discover/search/detail/image URL resolution/本地查询与 upsert。

所有 domain types 仍不依赖 Flutter、Dio 或 Drift。

## Parser contract

`EhHtmlParser` 是纯 Dart parser，目前覆盖：

- 画廊卡片、相对 URL、thumbnail、按 gid 去重、`dnext` cursor。
- 标题、类别、上传者、页数、封面、namespace:key tags。
- 详情阅读 page links：去重并按页码排序。
- `#img` 真正图片地址。

`test/fixtures/` 只保存匿名合成 HTML，不提交真实会话、Cookie、私有画廊链接或用户数据。`test/gallery/eh_html_parser_test.dart` 为 parser contract；页面结构变更时先补 fixture/test，再修改 parser。

## Repository behavior

- `discover` / `search` 根据明确 `SiteSource` 创建 HTTPS URL，使用 `SiteHttpClient` 继承认证与请求头策略。
- 所有成功列表/详情解析会 upsert 到 Drift `galleries`，不把 Cookie、响应原文或 token 复制到数据库。
- `loadDetail(includePageLinks: false)` 为默认值，避免打开详情页就处理上千 page links。
- `resolveImageUrl` 按 URL host 判定站点，支持 force refresh token；真实 Reader 之后将配合短 TTL `image_url_cache_entries` 使用。

## 当前不做

- 不抓取或提交真实站点 HTML。
- 不在 Widget 内直接调用 Repository。
- 不实施 HTML 正则之外的错误静默回退；解析失败应是 `NetworkFailureKind.parseFailure`。
- 不接入云收藏、评论、预览 strip、种子。这些放入后续 Gallery 子阶段。

## 下一阶段

建立 Home/Search Notifier、加载/空/错误/retry state 和实际 Gallery UI；先保持发现、详情、搜索的功能路径清晰，再实现 Tags 翻译、排行榜和收藏。
