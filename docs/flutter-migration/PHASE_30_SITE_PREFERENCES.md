# Phase 30：Persisted Site Preferences

## 已实现

新增 SitePreferences domain/data/provider：

- 默认 source：E-Hentai
- 保存 source：E-Hentai / ExHentai
- SharedPreferences key：`taro.eh.site.source`

Settings 现在有“站点来源” radio controls。Home 的 E/EX segmented control 切换来源后也会写入同一 notifier。

## 初始化流程

Home 不在 DiscoveryNotifier build 中 watch 异步 preferences，避免 SharedPreferences 完成后 rebuild notifier 并清空正在加载的结果。改为 Home init 后：

```text
await SitePreferencesProvider.future
  -> DiscoveryNotifier.initializeSource
  -> load(force: true)
```

这样首次发现请求和后续 source switch 都使用明确、持久化的 SiteSource。

## 安全边界

Source 是非敏感 UI preference，不包含 Cookie 或 URL token。ExHentai 可被选择，但实际访问仍由 AuthSession/SiteHttpClient 验证；没有有效会话时显示正常的 authentication/access error。

## 测试

新增 SitePreferences copyWith domain test。
