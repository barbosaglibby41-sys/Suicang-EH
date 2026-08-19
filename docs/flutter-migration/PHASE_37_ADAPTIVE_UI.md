# Phase 37：Adaptive UI 基础

## 待办归档

迁移完成后的专项列表已写入：

```text
docs/flutter-migration/MIGRATION_TODO.md
```

其中包含 Reader/ImagePipeline 性能、长图 tiling、高分辨率 zoom、Custom ImageProvider、媒体真机验证、后台下载、迁移 bridge、Accessibility、Golden tests 与发布门禁。评论编辑/删除明确列为不做。

## 本阶段已实现

新增 `AdaptiveLayout` 统一断点：

- compact `< 600`：2 列
- medium `600...1023`：4 列
- expanded `>= 1024`：5 列

Home 和 Library 使用同一断点模型，不再各自硬编码不同 width threshold。

## 设计边界

- 断点只决定信息密度，不写死设备尺寸。
- iPad/Android tablet 的三栏 NavigationSplit 等价布局、Dynamic Type、VoiceOver/TalkBack 和 golden matrix 仍在 `MIGRATION_TODO.md`，不在本阶段伪称完成。
