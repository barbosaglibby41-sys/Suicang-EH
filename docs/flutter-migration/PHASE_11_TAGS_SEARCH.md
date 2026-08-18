# Phase 11：Tag Translation 与 Search Suggestions

## 已实现

- 复用 Swift 工程已有 `TaroEH/Resources/tag_translation_seed.json`，复制为 Flutter asset；不重复维护标签数据。
- `TranslatedTag` 领域模型：namespace、key、中文 name、intro。
- `TagTranslationRepository` 契约。
- `BundledTagTranslationRepository`：
  - asset JSON 加载
  - id/英文 key/中文名索引
  - 精确、前缀、包含匹配建议排序
  - 中文 token 转 E-Hentai 查询格式：`namespace:"key$"`
  - 支持 `-` / `~` 排除与模糊前缀
- Riverpod ready/suggestions providers。
- 首页搜索栏显示当前 token 的中文标签建议；点击建议会替换 token 并保留其余 query。
- DiscoveryNotifier 搜索前加载标签库，并把中文词转换为站点查询；UI 仍保留用户输入的原始 query。

## 架构边界

标签索引和转换不依赖 Widget、Dio 或 Drift。首页只读取 provider 和 dispatch 搜索，不直接读取 asset 或发送 HTTP。

## 当前限制

- 远端 EhTagTranslation 更新、版本元数据和本地覆盖尚未接入；本阶段只提供内置 seed 的稳定回退。
- 建议当前按最后一个空格 token 工作；namespace 的中文显示和更复杂的编辑行为留给 Search hardening。
- Flutter 资源约 4.1MB，CI 构建会包含它；后续可评估压缩/二进制索引，但先保证兼容与可回退。

## 下一步

接入收藏/历史 Repository presentation、标签订阅和云收藏；随后进行 iPad adaptive detail layout 与 accessibility/golden test。
