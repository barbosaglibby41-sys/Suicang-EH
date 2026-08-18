# Phase 32：Gallery Comment Interaction

## 已实现

- `GalleryInteractionRepository` domain contract。
- `EhGalleryInteractionRepository.postComment`：
  - trim content
  - 少于 3 字符拒绝
  - 使用统一 SiteHttpClient `postForm`
  - 参数 `commenttext_new` / `comment_submit_new=Post`
  - 成功后重新 GET detail 并解析最新 comments
- GalleryDetailNotifier `postComment` 状态处理。
- Gallery Detail 评论区增加发表评论底部面板，最大 2000 字，发送中状态和最小长度校验。
- 没有评论时但有 source URL 仍显示评论标题/发表评论入口。

## 安全与错误

POST 不进入 network retry/coalescing；401/403 由 SiteHttpClient 映射，UI 只展示通用错误，不泄露 Cookie 或响应原文。

## 未实现

评论投票、编辑、删除和分页仍未迁移；这些需要进一步确认站点表单协议和权限语义。

## 测试

新增短评论拒绝测试，保证不触发网络请求。
