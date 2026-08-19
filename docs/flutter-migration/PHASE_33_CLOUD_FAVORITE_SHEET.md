# Phase 33：Cloud Favorite Category Sheet

## 已实现

- 详情页账户收藏操作不再固定写入收藏夹 1。
- 新增 `CloudFavoriteSheet`：
  - 读取服务端/默认十个收藏夹
  - 选择目标 folder 0...9
  - 根据当前已加载 CloudFavorites 状态显示加入/移除
  - 通过 CloudFavoritesNotifier 执行统一 POST 协议
- CloudFavoritesNotifier 新增 `contains` 和 `setFavorite`，更新当前列表状态。
- 本地收藏仍完全独立，不会因为账户收藏动作改变 `LibraryEntries`。

## 协议边界

仍使用已实现的 `favcat=0...9` 加入、`favcat=-1` 移除，不猜测评论投票协议。原 Swift 工程没有发现可迁移的 comment vote/delete implementation，因此评论互动本阶段不扩展未验证字段。

## 测试/验证

Cloud Favorites parser 与现有 POST path 保持不变；下一步可增加 notifier fake repository 测试，覆盖 category switch、contains 和 remove 列表更新。
