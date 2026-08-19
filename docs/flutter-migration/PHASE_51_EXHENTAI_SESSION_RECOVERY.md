# Phase 51：ExHentai Session Recovery

## 问题

ExHentai 有时以 HTTP 200 返回 Sad Panda / restricted access / session 页面。旧逻辑只按 HTTP status 判断成功，HTML parser 得到零作品，发现页错误显示“没有找到可显示的作品”。

## 修复

- EhGalleryRepository 在解析 ExHentai 列表前识别 Sad Panda、restricted access、igneous/login 访问拒绝正文。
- 命中后抛出 `authenticationRequired`，不再作为空列表。
- Discovery 首页首次加载 ExHentai 遇到认证失效时自动调用 `refreshExHentaiSession()` 一次，再重试列表请求。
- 仍失败时显示明确中文提示，指导到“账户与会话”验证/刷新 ExHentai。
- 切换 E/EX 来源时保留 `preferPublicDetailRedirect` 偏好。

## 用户操作

若自动刷新仍失败：

```text
设置 → 账户与会话 → 刷新 ExHentai 会话
```

或者重新通过 Web 登录导入实际站点 Cookie。不要只导入 E-Hentai 不完整 Cookie；ExHentai 需要有效的 `igneous` 和账户会话。
