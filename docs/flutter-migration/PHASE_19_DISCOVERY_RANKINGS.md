# Phase 19：Popular、Random Discovery 与 Rankings

## 已实现

扩展 GalleryRepository/EhGalleryRepository，复用既有 SiteHttpClient、HTML parser、Drift upsert 和 Gallery detail route：

- `popular(source)`：`/popular`。
- `rankings(source, period, page)`：`/toplist.php?tl=...&p=...`。
- `random(source, count, excluding)`：先读取发现页的最新 gid，再以 bounded random `next` cursors 采样；按 gid 去重且限制 8 次请求，避免无限请求。

新增 Rankings feature：

- `RankingPeriod`：昨日(15)、上月(13)、去年(12)、总榜(11)。
- 独立 Rankings notifier/state/UI 路由 `/rankings`。
- 排行作品复用 Gallery detail navigation。
- 首页新增热门、随机、排行入口；不新增并行网络层或独立 DTO。

## 约束

热门页是否具有可继续的 cursor 取决于服务器页面。当前 API 解析 next cursor，但 UI 没有把 `/popular` 伪装为无限流；只有明确返回 cursor 的 discover/search 才继续分页。

随机发现使用 `Random.secure()` + bounded retry/dedupe，而不是臆造私有 random API。

## 后续

排行榜的下一页 cursor/parser 仍需从站点 toplist fixture 进一步验证，才可启用 full ranking 无限加载。下一阶段建议处理 Gallery Detail parity：信息卡、评论、preview strip、torrent action。
