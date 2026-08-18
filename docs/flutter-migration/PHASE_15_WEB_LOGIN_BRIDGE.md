# Phase 15：Native Web Login Cookie Bridge

## Plugin

新增 path plugin：`packages/taro_web_login_bridge`。

Dart API 只暴露 `authenticate(initialUrl)` 并返回结构化 Cookie；认证 feature 的 `NativeWebLoginCookieBridge` 立即把它们转换为 `SessionCookie`，`WebLoginService` 立即调用 `AuthRepository.replaceCookies()`，最终只落在 `flutter_secure_storage`。

## iOS

- 使用 `WKWebView` + `WKWebsiteDataStore.nonPersistent()`。
- 使用 `WKHTTPCookieStore.getAllCookies`，而不是 `document.cookie`。
- 原生 CookieStore 可以读取 WebKit 暴露的 HttpOnly Cookie metadata，因此桥接不会依赖 JS。
- 当捕获到 `ipb_member_id` 时结束登录会话；用户取消返回 typed platform error。

## Android

- 使用原生 `WebView` + `CookieManager`。
- CookieManager 在 Android API 中可取 Cookie header，但没有公开 HttpOnly metadata；bridge 会按结构化记录回传，`httpOnly=false` 仅代表 metadata 不可得，不代表 cookie 不安全。
- Dart 仍只将 value 写入 secure storage。

## UI

Account 页面新增“网页登录”：平台 WebView 成功返回后显示成功提示，SessionProvider 会更新。Cookie 导入仍作为可靠的手动路径保留。

## 安全要求

- 不使用 JavaScript 读取 Cookie。
- 不将 Cookie value 写到 Drift、UserDefaults、日志、SnackBar 或测试 fixture。
- 使用 non-persistent WebView store，登录页面本身不会长期保留额外浏览数据；成功的 session 由 SecureAuthRepository 精确保存。

## 验证限制

iSH 不能编译 Flutter iOS/Android host。GitHub Actions 必须在生成 `ios/` / `android/` 后实际构建，且需要真机验证 E-Hentai 登录和 ExHentai refresh。任何验证都不得提交真实 Cookie。
