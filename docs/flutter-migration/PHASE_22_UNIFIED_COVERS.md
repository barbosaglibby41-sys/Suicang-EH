# Phase 22：Unified Gallery Covers

## 问题

Home、Library、Cloud Favorites、Rankings 之前各自使用静态 placeholder，即使 Gallery 已有 thumbnail URL，也没有进入 ImagePipeline。这会造成详情页和列表页表现不一致，并可能诱发后续多套 image loader。

## 方案

新增 `GalleryCover`：

```text
Gallery.thumbnailUrl exists
  -> PipelineImage
  -> ImagePipeline memory/disk/coalescing

thumbnail missing
  -> GalleryCoverPlaceholder
```

列表 surfaces 全部使用这个组件：Home、Library、Cloud Favorites、Rankings。variant 按展示密度选择：排行榜小图用 thumbnail/240px，其他 cover 用 cover/720px。

Detail 页面保留直接的 PipelineImage，因为它需要 Hero、固定 viewport 与不同的 layout constraints；thumbnail 缺失时仍明确 fallback 到 GalleryCoverPlaceholder。

## 验收

新增 widget test 验证没有 thumbnail 的 Gallery 使用稳定 placeholder，不会创建网络请求。

## 后续

ImagePipeline 仍需要 codec-targeted downsampling、decoded bitmap cost、memory pressure hooks 及 Reader sprite profiling；本阶段只消除多入口封面渲染分叉。
