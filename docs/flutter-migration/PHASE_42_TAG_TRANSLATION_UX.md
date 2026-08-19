# Phase 42：Tag Translation Database + Search UX

## 翻译库更新

TagTranslationRepository 现在支持：

- 内置 asset seed
- Application Support 本地更新文件
- EhTagTranslation DatabaseReleases 远程更新
- 原子 `.part` 写入后 rename
- 远程失败时继续使用当前数据库
- 恢复内置版本
- 数据库版本、更新时间、标签数量、来源状态

Settings 新增“标签翻译数据库”入口，提供更新和恢复内置版本。

## 搜索补全

参考输入中文标签的工作流：

- 搜索框当前 token 输入中文后显示中文主标题 + `namespace : english key` 副标题。
- 点击建议会将当前中文 token 替换为完整 E-Hentai 精确标签：

```text
female:"footjob$"
```

不会只填 key，避免命名空间歧义。

## 详情标签

- 优先显示翻译库中文名称。
- 没有翻译时显示原始英文 `namespace:key`。
- 点击标签：跳转 Home 并搜索原始英文标签。
- 长按标签：切换本地订阅。

## 边界

标签数据库更新不包含 Cookie/用户数据；远程数据库解析失败不会覆盖当前本地可用库。
