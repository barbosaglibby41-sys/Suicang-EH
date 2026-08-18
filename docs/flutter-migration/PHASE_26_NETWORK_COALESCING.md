# Phase 26：Network Request Coalescing 与 Safe Retry

## 问题

ImagePipeline 已合并相同图片请求，但普通 HTML GET（详情、Reader manifest、搜索、Cloud Favorites）仍可能被多个 UI/Notifier 同时发出，造成重复请求和站点压力。

## 已实现

- `RequestCoalescer<K,V>`：同 key 的并发 operation 共享 Future，完成后自动移除。
- `NetworkRetryPolicy`：默认最多 3 次，线性 backoff + 小 jitter。
- `SiteHttpClient.getBytes`：
  - 无 CancelToken 的幂等 GET 以 URL/source/referer/image accept 组成 key，走 coalescer + retry。
  - 有 CancelToken 的请求绕开 coalescer/retry，保持每个下载/可见图片 consumer 的取消语义。
- 只 retry：timeout、connection/noConnection、5xx transient。
- 不 retry：cancel、401、403、parse/invalid 4xx，避免无效认证循环或重复副作用。

## 测试

- 同 key concurrent run 只执行一次 operation。
- transient timeout 重试到成功。
- authenticationRequired 不重试。

## 限制

POST form 保持不重试也不合并。只有未来能明确幂等性的 POST 才能单独设计 idempotency key。
