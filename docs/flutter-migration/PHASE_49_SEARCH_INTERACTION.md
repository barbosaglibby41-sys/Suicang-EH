# Phase 49：Search Interaction and Route Stack

## 已实现

- 详情标签搜索改用 `context.push`，保留 Detail route stack；搜索页返回可回到详情。
- Home 使用 `didChangeDependencies` 监听 query，兼容 StatefulShell 保活页面在同一实例内接收新 query。
- 搜索页顶部在可返回时显示“返回详情”按钮。
- 点击补全：写入完整 `namespace:"key$"`，立即执行搜索并收起键盘。
- 搜索提交：先 unfocus，再执行搜索。
- 清除搜索：先 unfocus，再回到发现内容。
- 搜索结果滚动：使用 `ScrollViewKeyboardDismissBehavior.onDrag`。
- 标签点击和补全不再依赖重新创建 Home widget。

## 用户流程

```text
Detail tag
  -> push Home?query=namespace:key
  -> Home detects changed query
  -> fills search field
  -> performs search
  -> keyboard stays dismissed
  -> top back pops to Detail
```
