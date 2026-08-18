# Flutter 迁移执行清单

## 当前结论

- 迁移基线固定为 `release-repo` HEAD `8b8043f`，不是未提交工作树。
- 当前 Swift 版本约 6.3k 行，功能较多但结构仍为原生 MVP + 持续迭代状态；应以 feature-first clean architecture 重建。
- P0：Cookie 协议、Image Pipeline、Reader、Download/Offline；P1：Gallery/Search/Tags/Favorites/History；P2：排行榜、评论、种子、网络诊断。

## 可追踪 parity matrix

| 能力 | 优先级 | Flutter 所属 | 验收 |
|---|---:|---|---|
| E/Ex 站点与显式 Cookie 规则 | P0 | auth + core/network | fixture 覆盖登录、403、igneous 刷新 |
| Gallery/详情/HTML parser | P1 | gallery/data | 保存 HTML fixture 的 parser test |
| 中文标签与补全 | P1 | tags + search | 中英文 token 转换/补全 tests |
| 图片缓存、解码、预取、去重 | P0 | core/image | 20 consumer 合并、超大图 memory test |
| 在线 Reader | P0 | reader | six modes、URL 失效重解析、进度 |
| 离线 Reader | P0 | reader + offline | 同一 engine / PageSource contract |
| 下载恢复/队列 | P0 | downloads + core/downloads | pause/resume/relaunch/reconcile |
| 收藏/历史/进度 | P1 | favorites/history/reader | Drift migration + watch query |
| 云收藏 | P1 | favorites/data | 分页与 add/remove contract test |
| 首页/随机/热门/排行榜 | P1 | home/rankings | cursor/dedupe test |
| 评论、预览、种子 | P2 | gallery | feature-level integration tests |
| iPad adaptive UI | P1 | app/router + presentation | 11/13 inch golden + interaction test |
| native data import | P0 发布门禁 | migration | idempotency/checksum/rollback dry run |

## 下一次编码前的操作顺序

1. 在新分支创建 Flutter 根工程，保留 `TaroEH/` 原生目录、`project.yml` 与发布工作流。
2. 建立 `analysis_options.yaml`、格式化/测试 GitHub Action；Action 运行 `flutter analyze`、`flutter test`、Android debug build（iOS build 使用 macOS runner）。
3. 只实现 `app/`、`core/errors`、`core/logging`、domain primitives、空路由/主题，先让 CI 绿。
4. 引入 Drift v1 schema 与 repository contract，建立 migration tests，再接 auth/network。
5. 在有 HTML fixture 之前禁止接真实站点 UI 作唯一测试手段。
6. 每批分别提交；不要携带现存未提交的 `diagnose-xcode.yml` 改动。

## 风险登记

| 风险 | 缓解 |
|---|---|
| Flutter 图像缓存默认行为不适合漫画 | 自建 request key、LRU/disk metadata、decode target、profile tests |
| ExHentai Cookie 细节回归 | logical jar + mocked response fixture + native WebView bridge integration test |
| SwiftData/Keychain 跨 bundle 不可读 | 原生一次性 export bridge；Cookie 默认重新认证 |
| 平台后台下载能力差异 | platform adapter；产品 UI 只承诺当前平台真实能力 |
| HTML 结构改变 | parser fixture/versioned contracts、typed parse errors、可热修复 source adapter |
| Reader rebuild/内存抖动 | engine 与 renderer 分离、细粒度 providers、设备 profile 门禁 |

## Definition of Done（每个阶段）

- `dart format --set-exit-if-changed .`
- `flutter analyze` 无 warning/error（新增代码不引入 ignore）。
- 相应 unit/widget/integration tests 通过。
- 新 domain 逻辑无 Flutter/Dio/Drift import。
- Cookie、URL token、用户路径不进入日志或测试输出。
- GitHub Actions artifact/日志确认；iOS 真机关键路径在实际设备 profile 验证。
