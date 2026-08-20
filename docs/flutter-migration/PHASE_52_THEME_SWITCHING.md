# Phase 52：Theme Switching

## 已实现

Settings 新增外观主题选择：

- 跟随系统
- 浅色主题
- 深色主题

主题设置保存在 SharedPreferences：

```text
suicang.eh.theme.preference
```

MaterialApp 根据 ThemePreference 动态应用 ThemeMode；切换立即生效，重启后保留。

## 默认

首次启动默认为深色主题，保留 Suicang 黑曜石视觉。用户可以自由切换白色主题或随系统切换。

## Reader 重试

用户明确取消 Reader 失败重试按钮需求。本阶段已撤销所有尚未提交的 Reader retry 参数/缓存清理改动，不影响 Reader 现有加载逻辑。
