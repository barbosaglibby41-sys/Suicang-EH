# Phase 34：Verified Comment Voting

## 协议确认

基于公开 JHenTai `eh_request.dart` 源码和 E-Hentai 页面 JS 命名，评论投票使用 detail page form POST：

```text
token=<detail page token>
comment_id=<comment id>
comment_vote=1 | -1
```

- `1`：顶
- `-1`：踩

这不是猜测字段：公开客户端实现使用同一 `comment_id` / `comment_vote` payload。实现仍要求先从当前 detail HTML 解析 token，token 缺失时拒绝发送。

## 已实现

- GalleryInteractionRepository 扩展 `voteComment`。
- EhHtmlParser 解析 comment vote token。
- EhGalleryInteractionRepository：detail GET → token parse → SiteHttpClient POST → detail GET refresh comments。
- Comment card 加入顶/踩按钮和请求中状态。
- 详情 Notifier 统一刷新 comments / 错误状态。

## 安全边界

投票 POST 不重试、不合并；认证/权限失败不泄露 Cookie 或原始页面内容。评论编辑/删除仍未实现，因为未确认安全、稳定的站点协议与权限条件。

## 测试

匿名 detail fixture 增加 token，parser contract 验证 token 提取。
