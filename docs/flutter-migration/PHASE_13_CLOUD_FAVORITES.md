# Phase 13：Cloud Favorites

## 独立数据边界

账户收藏没有写入 `LibraryEntries`。本地收藏与站点账户收藏有不同的认证、同步、分页和失败语义，因此分别实现：

- `LibraryRepository`：本地 Drift 收藏/历史。
- `CloudFavoritesRepository`：站点 favorites.php / gallerypopups.php 协议。

## 已实现

- `CloudFavoriteCategory`、`CloudFavoritesPage` 与 repository contract。
- `CloudFavoritesParser`：解析账号收藏夹目录、画廊条目与 `dnext` 分页；使用匿名 fixture contract test。
- `EhCloudFavoritesRepository`：
  - `favorites.php?favcat=N` 请求
  - 站点收藏分页
  - 从 gallery detail 解析 favorite token
  - `gallerypopups.php?act=addfav` form POST
  - `favcat=-1` 删除，`0...9` 加入标准文件夹
- `SiteHttpClient.postForm`：和 GET 使用同一 logical CookieJar、Referer、Set-Cookie 回写与 typed network errors。
- Cloud Favorites UI：收藏夹 picker、分页、刷新、空/错状态和详情跳转。
- Gallery Detail：独立云图标打开账户收藏列表；操作位支持加入账户收藏夹 1。失败会明确提示登录/会话要求，而不会写入本地收藏。

## 当前限制

- Flutter WebView 登录 cookie bridge 尚未实现。因此没有导入 Cookie 的用户会收到认证失败，这是正确行为。
- 详情页快捷操作默认写入收藏夹 1；完整选择/移除 sheet 将在 authentication UI 完成后添加。
- Cloud collection 不保存为本地 favorites cache；它反映当前服务器响应。Gallery metadata 仍可通过详情请求更新到 Drift。

## 下一阶段

实现 WebView 登录 Cookie bridge、Cookie 导入/状态页面和 ExHentai `igneous` refresh choreography。只有这一认证阶段完成后，Cloud Favorites 才具备完整可用闭环。
