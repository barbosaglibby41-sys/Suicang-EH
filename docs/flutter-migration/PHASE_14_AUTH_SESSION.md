# Phase 14：认证状态、Cookie 管理与 ExHentai Session Refresh

## 已实现

- Account UI：安全 Cookie 导入、会话数量/凭据状态、E-Hentai 验证、ExHentai 刷新、清除本机登录。
- `SessionService` / `EhSessionService`：
  - Cookie 缺失时明确 authenticationRequired。
  - 通过 SiteHttpClient 验证目标站点会话。
  - ExHentai refresh：清除所有 logical `igneous` → 请求 E-Hentai 补齐 session → 复制 `ipb_member_id/ipb_pass_hash/sk/nw/datatags` 到 ExHentai domain → 请求 ExHentai → 验证结果。
- `AuthRepository.removeCookiesByName` 按名称跨 logical domain 清理 stale values。
- `WebLoginCookieBridge` interface：为原生 WebView cookie store 提供明确边界，尤其是 HttpOnly Cookie。

## 安全边界

Cookie 只在 `flutter_secure_storage` 和内存 logical jar 内。Account UI 只展示数量和登录状态，永不回显 Cookie value。日志、Drift、assets、异常文本均不保存敏感值。

## WebView 状态

Flutter WebView 登录 bridge **尚未实现**。原因是普通 JS `document.cookie` 无法读取 HttpOnly Cookie，不能伪造“网页登录成功”。当前界面明确提示使用安全 Cookie 导入；下一阶段在 iOS/Android host 层实现 WebView CookieStore bridge 后再接入按钮。

## ExHentai 限制

刷新流程已按现有 Swift 逻辑建立，但是需要 fixture/mock transport 与真实已授权设备验证。不会在本仓库或测试中写入真实 Cookie。

## 下一步

1. 建立 iOS WKWebView / Android WebView CookieStore MethodChannel bridge。
2. 添加受控 mock HTTP fixture 验证 refresh cookie choreography。
3. 接入 WebLogin UI，完成 Cloud Favorites 认证闭环。
