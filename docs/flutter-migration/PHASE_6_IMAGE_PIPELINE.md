# Phase 6：ImagePipeline 与 Cache

## 目标

建立唯一图片加载边界，供封面、Gallery、在线 Reader 和离线 Reader 共用。Widget 不再使用 `Image.network` 或自行请求 URL。

## 结构

```text
PipelineImage
  -> ImagePipeline
    -> memory LRU
    -> disk cache
    -> SiteHttpClient
      -> logical CookieJar
```

## 已实现

- `ImageRequest`：URL、Referer、variant、targetPixels 组成稳定 cache key。
- `MemoryImageCache<Uint8List>`：LRU + decoded/response byte cost budget；新条目会淘汰最久未访问条目，超预算单项不保留。
- `DiskImageCache`：temporary cache 下的 SHA-256 文件 key、TTL、`.part` 原子写入、静默清理。
- `ImagePipeline`：memory → disk → network 顺序；相同 key 的并发请求共用同一个 Future；支持取消令牌、清理内存/磁盘和基础预取。
- `PipelineImage`：统一加载状态、错误状态、取消离屏请求、稳定尺寸渲染。
- Gallery Detail 封面已接入这条管线；没有创建第二套 cover loader。

## 安全与正确性

- cache key 不包含 Cookie value；请求仍通过 `SiteHttpClient` 动态获取 logical Cookie。
- 响应 Content-Type 若明确不是 `image/*`，不会写入图片缓存，避免 HTML 错误页污染 disk cache。
- 磁盘缓存位于 temporary directory，不是用户数据数据库；系统可回收，缺失时自动回源。
- URL、Referer、variant 变化会形成不同 key，避免跨页面/尺寸复用错误内容。

## 当前限制

Flutter codec 层的按 targetPixels 解码和长图分块尚未接入；当前缓存保存 response bytes，由 `Image.memory` 解码。Reader 阶段必须再加 codec/resize 策略，不能把此阶段的 cover pipeline 直接当作最终漫画大图方案。

当前 `prefetch` 是顺序实现，用于保持 API 边界；Reader 阶段会增加优先级队列、并发上限和 visible > adjacent > cover 的调度。

## 测试

- LRU cost eviction 与超预算条目不留存。
- 相同请求并发调用只产生一次 Dio transport 请求。
- Content-Type image 约束由管线执行。

下一阶段：Reader Engine + Online/Offline PageSource。Reader 会在此 Pipeline 上实现动态 decode、预加载、进度与统一阅读模式。
