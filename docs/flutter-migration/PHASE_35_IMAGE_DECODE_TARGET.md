# Phase 35：Targeted Image Decode

## 已实现

ImagePipeline 现在分为：

```text
file / disk / network raw bytes
  -> ImageDecoder(targetPixels)
  -> decoded PNG bytes + width/height
  -> memory LRU (width × height × 4 cost)
```

- Disk cache 仍保存原始网络 bytes，避免重复请求。
- Memory cache 保存按 ImageRequest targetPixels 解码后的 bytes。
- LRU cost 由实际像素估算，不再错误使用压缩 JPEG/PNG 文件大小。
- ImageRequest targetPixels 被限制在 1...4096，防止异常调用申请无上限 decode。
- 同 URL 的 thumbnail/cover/reader request 通过 variant + targetPixels 分别缓存，避免 Reader 使用低清 cover 或 cover 解码原图。

## 目标

减少大漫画页（3000px / 5000px+）因完整原图 raster 化引起的峰值内存。Reader 当前使用 1600 targetPixels；cover 720；ranking thumbnail 240。

## 限制

- Flutter codec 仍在 UI isolate API 内，尚未实现 isolate-based decode/long-strip tiling。
- `ui.ImageByteFormat.png` 会增加一次 PNG encode；后续可评估 custom ImageProvider 直接持有 ui.Image，以进一步降低 copy/encode。
- 超过 4096px 的 zoom quality 由后续 high-resolution on-demand strategy 处理。

## 测试

现有 ImagePipeline coalescing test 注入 passthrough decoder，不依赖平台 codec；文件图片测试继续覆盖 file URI bypass。
