# Phase 46：Gallery Card Published Metadata

## 已实现

新增共享 `GalleryCardMeta` 组件，统一 Home、Library、Rankings、Cloud Favorites 卡片底部信息：

```text
分类 · 页数 · 相对发布时间
```

例如：

```text
Manga · 27 页 · 3 小时 12 分钟前
```

如果分类、页数或发布时间缺失，会自动隐藏对应字段，不显示空占位。

发布时间复用 `RelativeTime`，支持秒、分钟、小时、天、月、年；详情页仍保留 Tooltip 中的完整绝对时间。

## 视觉

- 使用低对比 labelSmall
- 单行省略，避免卡片高度漂移
- 统一列表、书架、排行、云收藏的 metadata 密度
- 不增加卡片额外大面积背景

## 测试

新增 GalleryCardMeta widget test，验证分类、页数和相对发布时间同时显示。
