# Phase 38：Accessibility Foundation

## 已实现

- GalleryCover / placeholder：提供 image semantic label，包含作品标题。
- Home Gallery tile：保持 button semantics 和作品标题；图片语义由 GalleryCover 提供。
- Reader bottom progress：以 liveRegion 语义播报当前页、总页数和完成百分比。
- 现有 IconButton、SearchBar、导航和 Sheet controls 使用 tooltip/label，继续由 Flutter semantics tree 暴露。
- 新增 GalleryCover semantics widget test。

## 待办

完整 VoiceOver/TalkBack focus order、Dynamic Type、大字体布局、44x44 触控目标、Reduce Motion、高对比度和 golden matrix 已写入 `MIGRATION_TODO.md`，本阶段不伪称全部完成。
