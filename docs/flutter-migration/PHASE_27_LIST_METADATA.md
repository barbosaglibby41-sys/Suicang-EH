# Phase 27：Gallery List Metadata

## 问题

列表 parser 原先只映射 gid、标题、链接和封面，导致 Home、Popular、Random、Rankings、Cloud Favorites 的 Gallery card 缺少页数、作者、分类、评分、发布时间和 tags，即使站点列表 HTML 已包含这些字段。

## 已实现

`EhHtmlParser.galleriesPage` 现在以 `id="it<gid>"` 定位每个列表行，并限制解析范围到同一个 `</tr>`：

- thumbnail（data-src / img src）
- page count
- category (`.cn`)
- uploader (`.gl4c`)
- posted date (`postedpop_<gid>`，可解析时为 DateTime)
- average rating
- tags (`.gt title`)

随后同一行 metadata 映射进 Gallery entity，EhGalleryRepository 的既有 Drift upsert 自动保留该提升后的数据。

## 隔离规则

metadata 解析保留在 parser data source；Home/Rankings/UI 不执行 HTML 字符串处理。每项只扫描其行，避免相邻 Gallery 的 author/tag 泄漏。

## 测试

匿名 listing fixture 扩展了 category/uploader/page/rating/tag 字段，parser contract 验证这些值映射到第一个 Gallery。

## 后续

继续评估真实 E-Hentai table/list layout fixture 的各种 card variations，尤其是 Compact/Extended list mode；不能假设单一 HTML 布局永久稳定。
