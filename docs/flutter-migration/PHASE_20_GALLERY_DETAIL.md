# Phase 20：Gallery Detail Metadata 与 Comments

## 已迁移

Detail parser/DTO 现在包含：

- Language
- File Size
- Favorite count
- Rating count
- Torrent URL
- 评论 author / postedAt / score / uploader 标记 / votes / HTML 转文本 content

`GalleryDetail` 承载 transient metadata 与 comments，保持 `Gallery` 数据库行的轻量性；不会将会频繁变化的 comments 写入本地 Gallery 表。

## Parser 约束

- 继续使用匿名合成 HTML fixture，未提交真实 Gallery、账号、Cookie 或评论内容。
- 评论扫描限制在 `#cdiv → #chd` 区域，避免长详情页整页匹配。
- `<br>` 转换为换行，文本支持 SelectableText。

## UI

- Detail 页面增加六项 metadata card：语言、页数、发布日期、大小、收藏次数、评分。
- 评论列表展示上传者标记、分数、正文、时间与 votes。
- Detail Notifier 统一将 metadata/comments 置入 `GalleryDetailState`；UI 不执行 HTML 或网络逻辑。

## 未完成

- 评论翻页、发评论、投票需要站点授权 POST 协议和输入安全策略，暂不实现。
- Preview sprite strip 和 torrent 下载/share action 将作为后续独立小阶段。
- Gallery 持久化 schema 未增加 metadata columns；若未来需要离线 details cache，应进行明确 schema migration，而不是隐式塞入 tags JSON。
