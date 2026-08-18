# Phase 24：Reader Settings UI

## 已实现

新增 `ReaderSettingsScreen`，从 Settings 页面进入，与 Reader 控制栏复用同一个 `ReaderPreferencesNotifier`：

- 默认阅读方式：横向分页 / 纵向长条
- 默认方向：LTR / RTL
- 默认页面适配：完整显示 / 填充屏幕
- 阅读时保持屏幕常亮偏好

每项选择立即调用 notifier 保存 SharedPreferences；下次 Reader 初始化按已保存偏好构建 Engine。

## 边界

设置页不直接访问 SharedPreferences。`keepScreenOn` 当前只保存偏好，不谎称已生效；需要后续 iOS/Android wakelock platform adapter 才可控制系统 idle timer。

## 测试

新增 widget test，验证阅读设置的核心 controls 出现。

## 下一阶段

实现 KeepScreenOn platform adapter（iOS UIApplication idleTimerDisabled / Android FLAG_KEEP_SCREEN_ON），仅在 Reader 可见且偏好开启时激活，退出 Reader 必须恢复系统默认状态。
