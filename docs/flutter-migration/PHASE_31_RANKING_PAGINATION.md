# Phase 31：Rankings Pagination 与 Persisted Source

## 已实现

- 新增 `RankingPage(galleries, nextPage)`。
- GalleryRepository rankings API 不再复用 GalleryPageResult cursor；EhGalleryRepository 解析 toplist HTML 中明确的 `toplist.php?...&p=N` 下一页。
- RankingsNotifier 每个 RankingPeriod 保存独立 galleries、nextPage 和 loadingMore set。
- loadMore 时按 GalleryKey 去重，并只有 parser 返回 nextPage 时显示加载更多。
- Rankings initialize 读取 SitePreferences，与 Home 选择的 E-Hentai / ExHentai 来源一致。

## Parser Contract

新增匿名 fixture `toplist.php?tl=15&p=1` 链接，验证 `EhHtmlParser.toplistNextPage(html, 0) == 1`。不会从普通 dnext cursor 推断排名下一页。

## 约束

Toplist 的服务器可能在某些 source/period 不提供下一页；UI 仅展示服务器明确信号，不伪造无限流。

## 后续

需要在授权设备实际确认 ExHentai toplist 响应是否和 public endpoint 一致。若差异明显，新增 source-specific fixture 和 parser contract，而不是在 UI 中增加例外逻辑。
