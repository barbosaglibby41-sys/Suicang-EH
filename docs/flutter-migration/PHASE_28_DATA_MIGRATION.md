# Phase 28：Non-sensitive Data Migration Importer

## 已实现

`MigrationImporter` 使用现有 Drift `migration_journal`，支持导入非敏感 bundle：

- galleries metadata
- local favorites
- history
- reading progress

导入在一个 Drift transaction 内：journal 先标记 running，完成后标记 completed 并记录 SHA-256 checksum 和 importedAt。相同 bundle id + checksum 的 completed import 再次执行会返回 no-op。

## 安全边界

迁移 bundle 格式明确禁止：Cookie、Keychain 数据、WebView session、密码、token、API key、私有文件路径。认证仍需要 Web 登录或手动 Cookie 导入到 secure storage。

Importer 不删除、移动或修改 Swift 原项目数据。Flutter import 完成后，用户必须先验证 Library/History/Progress，再自行决定是否移除旧 App。

## 当前限制

- 尚未创建 iOS native SwiftData/UserDefaults export bridge。
- 尚未创建 Flutter 文件选择 UI；当前 importer 是 core service + schema/test foundation。
- 下载 file copy/verification 需要独立 migration phase，不能只导入 metadata 后声称离线副本已迁移。

## 验收

测试验证：首次导入写入 Gallery/Favorite/History/Progress，第二次同 bundle 导入无重复写入，journal 为 completed。
