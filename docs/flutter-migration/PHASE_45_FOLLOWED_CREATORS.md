# Phase 45：Follow Artists / Uploaders

## 入口

Gallery Detail 操作区新增：

```text
关注作者
关注发布者
```

- 作者：优先从 `artist:<name>` tag 提取。
- 发布者：使用 Gallery uploader。
- 再次操作同一 source/kind/value 时取消关注。

详情顶栏“关注”图标打开关注页。

## 数据与更新方式

E-Hentai/ExHentai 没有可依赖的实时作品推送协议，因此不伪造实时通知。

```text
关注页打开 / 用户点击检查新作品
  -> 按 artist tag 或 uploader keyword 搜索
  -> 按发布时间排序
  -> 更新 lastCheckedAt / lastSeenPublishedAt
  -> 显示作品横向列表
```

用户打开关注页后可一键检查每个已关注源。后续平台 Background Task 可复用此 Repository，但需要单独平台验证。

## 数据库

Drift schema v3 新增：

```text
followed_creators
```

字段：source、kind、value、displayName、createdAt、lastCheckedAt、lastSeenPublishedAt。

## 约束

- 关注为本地功能，不写入站点账户。
- 关注不会影响本地收藏/云收藏。
- 书架已有的“账户收藏”仍独立。
- uploader 搜索依赖站点 keyword 匹配；artist 使用精确 `artist:"name$"` tag 搜索。
