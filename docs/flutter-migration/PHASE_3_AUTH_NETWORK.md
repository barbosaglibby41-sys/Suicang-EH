# Phase 3：认证、Cookie 与网络传输边界

## 范围

本阶段实现安全 Cookie 持久化、结构化 Cookie 模型、显式请求头策略、Dio transport 和类型化错误。尚未连接 WebView 登录 UI、ExHentai 自动刷新或真实站点 parser；这些会在具有 HTTP fixture 与平台 bridge 后接入。

## 安全边界

- `SessionCookie` value 仅存在于内存和 `FlutterSecureCookieStore` 内：后者使用 `flutter_secure_storage`，即 iOS Keychain / Android encrypted storage。
- Cookie **不写入 Drift、SharedPreferences、普通文件、日志、测试输出或 UI state**。
- `SecureCookieStore` 是接口，因此测试只使用内存 fake，绝不触及设备 Keychain。
- 导入 Cookie 时只接受 `name=value; name2=value2`，并把结构化副本写入两个必要站点域；无合法 pair 会抛出 `ValidationException`。

## 逻辑 Cookie Jar

`SecureAuthRepository` 是唯一认证状态来源：

1. 启动时从 secure storage 读取并移除已过期项。
2. 更新按 `name + domain + path` 合并，避免同名跨域覆盖。
3. 请求按 host 过滤 Cookie；E-Hentai 和 ExHentai 的相同 gid/会话不会混淆。
4. `watchSession()` 向 presentation 暴露不可变会话快照；Provider dispose 时关闭 stream。

## Dio SiteHttpClient

- 每次请求通过 `AuthRepository.cookiesFor(source)` 生成明确 `Cookie` header，不将 Dio 的隐式 cookie jar 作为事实来源。
- `EhRequestPolicy` 统一 UA、Accept、Accept-Language、Referer 与图片 Accept。
- `Set-Cookie` 被结构化解析并回写 secure jar。
- 401 / 403 与 Dio timeout/cancel/connection error 映射为 `NetworkException`，供上层 Notifier 处理。
- 目前无盲目 retry：只会在未来为明确幂等、可重试的 GET 加入有上限的退避策略。

## 尚未实现（刻意留在下一小阶段）

- WebView 登录后 Cookie bridge。
- ExHentai `igneous` refresh choreography：清旧值 → E-Hentai 补齐 `sk/nw/datatags` → 域复制 → ExHentai 验证 → 保存有效值。
- HTML parser 和真实站点 repository：先创建匿名 HTML fixture 与 contract tests。
- 代理/DoH：不承诺仅靠 Dio settings 就可安全实现；需单独 platform/network adapter 设计。

## 测试

- Cookie header 解析：双域复制、`=` 保留、格式拒绝。
- 请求 policy：只向匹配 source 发送 Cookie，Set-Cookie 的 domain/secure/httpOnly 保持结构化。
- Repository：合并、按域过滤、clear。

下一阶段先添加匿名 HTML fixture、Gallery DTO/parser 和 GalleryRepository；随后再把认证后的 transport 接入真实功能。
