# Phase 23：Reader Preferences Persistence

## 已实现

Reader preferences 已从硬编码值迁移为独立 domain/repository：

- mode：horizontal / vertical
- direction：LTR / RTL
- fit：contain / cover
- keepScreenOn（预留，尚未接入系统 idle timer bridge）

`SharedPreferencesReaderPreferencesRepository` 保存非敏感 UI preference；Cookie、下载、进度和 Gallery 数据不进入 SharedPreferences。

Reader 启动顺序：

```text
ReaderPreferencesRepository.load
  -> ReadingProgressRepository.get
  -> ReaderSessionConfig
  -> MangaReaderEngine
```

Reader controls 修改 mode/direction/fit 时，先立即更新 Engine，再异步保存 preferences。下次打开任何在线/离线 Reader 会恢复相同偏好。

## 架构边界

Widget 只调用 ReaderPreferencesNotifier；SharedPreferences 实现留在 data 层。Reader domain 不 import Flutter 或 SharedPreferences。

## 未完成

- iOS/Android keep-screen-on 平台 bridge。
- Settings 页面中的完整 Reader settings form。
- 双页、vertical visibility、codec downsample 等 Reader hardening 后续项。
