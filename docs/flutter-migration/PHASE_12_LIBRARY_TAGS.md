# Phase 12：Local Library、History 与 Tag Subscriptions

## 本地收藏与历史

`LibraryRepository` 已从 placeholder 进入真实 Drift workflow：

- Gallery Detail 打开时 `recordOpened`，书架历史流立即更新。
- 收藏按钮读取和切换 `LibraryEntries.isFavorite`。
- Library 页面有“收藏 / 历史”两个 Tab，以 watch query 实时显示响应式网格。
- `DriftLibraryRepository` 修复字段覆盖问题：
  - 收藏更新不清除已有 `lastOpenedAt`。
  - 记录打开不清除已有 `isFavorite`。

本地收藏和站点账户收藏明确分离；没有把 cloud favorite 混入 `LibraryEntries`。

## 标签订阅

- 新增 `SubscribedTagsRepository` 与 Drift 实现。
- `SubscribedTags` 表以 raw `namespace:key` 为主键。
- Gallery Detail tags 使用 ActionChip；点击切换本地订阅，通知 icon 表达当前状态。
- Stream provider 使详情页状态跟随数据库更新。

## Cloud Favorites 状态

当前没有实现云收藏 UI 或 API。它依赖：

1. WebView 登录 Cookie bridge。
2. ExHentai session refresh 完整流程。
3. cloud favorites HTML parser、分页和 POST favorite protocol。

这些必须作为 authentication + favorites data feature 实现，不能复用本地收藏 Repository 伪装同步。

## 测试

- Drift subscribed tags toggle test，确认重复切换不会产生重复 row。
- 后续应增加 LibraryRepository transaction test：收藏/历史字段在任意写入顺序后都不会被覆盖。
