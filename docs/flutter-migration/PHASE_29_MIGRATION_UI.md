# Phase 29：Migration Import UI

## 已实现

Settings 新增“导入旧版数据”入口与 `MigrationImportScreen`：

- 系统文件选择器只接受 `.json`
- 在内存中读取，最大 10MB
- UTF-8 JSON 交给既有 MigrationImporter
- 显示首次导入的 Gallery/Favorite/History/Progress 计数
- 已导入的同 bundle 显示 no-op 结果
- 明确告知非敏感边界和旧 App 数据不会被修改

## 安全

UI 不读取、展示或导入 Cookie/Keychain/密码/token/API Key/离线路径。FilePicker bytes 只在导入期间使用，不保存到应用目录。

## 后续

真正从 Swift App 导出 bundle 仍需 native SwiftData/UserDefaults export bridge。该 UI 接收的是用户从旧 App 或 Files 导出的 schema-compatible JSON；没有该 export bridge 时，用户无需尝试从 Keychain 导出认证数据。
