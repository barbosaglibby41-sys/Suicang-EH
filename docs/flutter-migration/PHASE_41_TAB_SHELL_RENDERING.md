# Phase 41：Bottom Tab Rendering Stability

## 问题

原 `ShellRoute` 使用单一动态 child。每次底部 tab `context.go()` 会替换并销毁当前 child subtree；复杂 ScrollView、Image Future、Hero、异步 provider 在 Flutter 合成层/容器运行时中可能留下旧帧，表现为切换底部功能页时画面残留。

## 修复

迁移为 GoRouter 官方：

```text
StatefulShellRoute.indexedStack
```

每个底部 tab 使用独立 Navigator branch：

- Home
- Library
- Downloads
- Settings

切换通过 `StatefulNavigationShell.goBranch()`，内部用 IndexedStack 保留各分支状态，不再复用单一动态 child。内容容器增加 `RepaintBoundary`，隔离 tab body 的 GPU/compositor repaint。

## 交互设计

- 点击当前 tab：回到该 tab 初始路由。
- 切换其他 tab：保留原 tab scroll、Future、provider 和 Navigator 状态。
- Detail、Reader、Rankings、Account、Cloud Favorites 仍位于底部 shell 外，避免底栏/旧帧泄入全屏流程。

## 测试

新增 app shell widget test，验证 NavigationBar 存在且 Home/Library 分支可稳定切换。
