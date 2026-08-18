# Phase 18：Search History

## 已实现

- 使用已有 Drift `search_history_entries` 表；新增 SearchHistory domain entity/repository/data implementation。
- 成功完成的搜索会记录原始用户 query，不记录中文标签转换后的站点 query。
- 同一 query 再次搜索时旧记录先删除，新记录写入当前 UTC 时间，因此最近搜索不会重复且会提升到顶部。
- 首页仅在搜索框当前 token 为空时显示最近搜索。
- 最近搜索支持：点击立即搜索、单条删除、清除全部。

## 隐私

搜索历史保留在本机 Drift 数据库，不上传、不与 Cookie 或账户会话关联。用户可从首页一键清除。

## 测试

- 去重并提升最近使用记录。
- 单条删除与全量清除。

## 下一阶段

实现 Gallery Ranking / Popular / Random Discovery，与既有首页 discover 搜索共享 GalleryRepository 和 parser；随后进行详情信息、评论、预览和种子等 Gallery parity 功能。
