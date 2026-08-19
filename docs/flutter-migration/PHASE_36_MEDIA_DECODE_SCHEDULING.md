# Phase 36：Reader Media、Decode Scheduling 与 Zoom Prefetch Foundation

## 已实现

- `DecodeScheduler`：visible decode 优先于 prefetch，默认最多 2 个并发 decode。需要说明：Flutter `dart:ui` codec 最终只能在 UI isolate 使用；本阶段把请求规划/bytes transport/优先级排队移出渲染调用，codec 在受限 UI scheduler 执行，避免不支持的普通 isolate `dart:ui` 调用。
- `MediaKindResolver`：image / animatedImage (gif/webp) / video (mp4/m4v/mov/webm)。
- Reader `ReaderMedia`：静态图片、动态图保留原始 bytes 交给 Flutter image decoder、视频使用 `video_player`，网络视频带 logical Cookie header，file 视频走本地 controller。
- Reader 页面加载遇到 video 时跳过静态 ImagePipeline decode，直接交给 video renderer。
- 现有 Reader 可见页/邻页 preload stream 进入同一 DecodeScheduler；visible request 使用更高优先级。
- zoom 仍由 Reader Engine 控制 1x/2x，targetPixels 已为 reader 1600；后续可在 zoom > 1 时用另一 cache variant 请求更高分辨率。

## 限制与后续

- 真正的超长图 tiling 需要 page source/renderer 提供 tile manifest 或区域解码 API；不能把普通整图裁剪称为 tiling。当前 CustomPainter sprite crop 只用于详情预览雪碧图。
- `video_player` 平台权限、Cookie-protected streaming 和动态图帧内存需在 iOS/Android 真机测试。
- 当前 `ImageDecoder` 输出 PNG bytes 作为兼容层；最终 Custom ImageProvider 直接持有 `ui.Image` 可减少 encode/copy，应在 profile 后实施。

## 测试

新增 MediaKindResolver test；离线/图片管线测试使用可注入 decoder，避免测试 fake bytes 被真实 codec 错误解释。
