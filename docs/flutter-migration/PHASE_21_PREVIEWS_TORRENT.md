# Phase 21：Preview Sprite Strip 与 Torrent Action

## Preview Sprite Strip

- 新增 `PagePreview`：page、sprite URL、CSS x/y offset、tile width/height、page URL。
- EhHtmlParser 只扫描 `#gdt → #gdo` 预览区，解析站点雪碧图 CSS 规则，按页码去重并默认限制 20 项。
- `PreviewStrip` 通过统一 ImagePipeline 请求 sprite image；使用 `ui.instantiateImageCodec` 与 CustomPainter 依据 CSS 像素 offset 绘制单个 tile。
- 不逐 tile 发网络请求；同一 sprite URL 会被 ImagePipeline cache/coalescer 复用。
- Detail state/UI 显示横向内容预览条。

## Torrent Action

- Detail metadata 中若已有 `.torrent` URL，优先使用。
- 缺失时 `GalleryRepository.torrentUrl()` 请求 `gallerytorrents.php?gid=...&t=...`，解析 direct `.torrent` href。
- UI 只调用 Notifier，再用 `url_launcher` 经系统外部 handler 打开 torrent URI；不在 App 内实现 BitTorrent client，也不伪造下载成功状态。

## Fixture/Test

匿名 detail fixture 已增加 sprite tile，parser contract 验证 page、sprite URL 与 yOffset。

## 当前限制

- Preview strip 目前只显示前 20 页，不承担 Reader 跳页导航。
- codec/image disposal 和超大 sprite decode 的内存 profile 需在真机 Reader performance 阶段验证。
- torrent popup 页面结构仍需有授权真机测试；解析失败会返回 null，UI 不会显示成功。
