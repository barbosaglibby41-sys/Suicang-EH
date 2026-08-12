# 芋头 E 站

原生 SwiftUI E-Hentai/ExHentai 客户端。当前版本为 v1.7，完成双站点模型、结构化标签、SwiftData 画廊持久化、Cookie 感知图片管线、真实首页/随机发现基础和站点隔离缓存。保留 v1.6 的标签翻译库、中文搜索转换与补全功能。

## 登录方式

1. **内置网页登录**：使用 WKWebView 登录，登录完成后读取站点 Cookie。
2. **Cookie 导入**：从系统剪贴板粘贴 Cookie 文本；解析后仅保存到本机 Keychain。

## 安全说明

- 不设置第三方中转服务器。
- 不在日志中输出 Cookie、账号或密码。
- Cookie 使用 Keychain 存储。
- 使用前请确认遵守目标网站规则及当地法律。

## 构建

将 `TaroEH` 文件夹加入 Xcode，配置自己的 Bundle Identifier 和签名，即可用个人 Apple ID/开发者账号构建并侧载。

最低系统目标：iOS 17。建议在 iOS 27 beta 上使用最新 Xcode beta 编译。
