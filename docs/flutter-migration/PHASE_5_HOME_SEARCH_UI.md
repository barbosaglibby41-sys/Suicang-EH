# Phase 5：发现、搜索与 Gallery Detail Presentation

## 范围

本阶段将 Flutter 首页从迁移占位替换为真实的 presentation workflow：发现、站点切换、搜索、分页、加载/空/错误/重试状态，以及画廊详情路由与 metadata hydrate。业务请求仍经 `GalleryRepository`，Widget 不直接访问 Dio、Drift 或文件系统。

## 状态设计

`DiscoveryNotifier` 管理不可变 `DiscoveryState`：

- source、当前 query、discover/search mode。
- 首次 loading、分页 loading、cursor。
- 结果按 `GalleryKey` 去重，防止站点 cursor 重叠时显示重复项目。
- 有内容时分页失败显示 inline error；无内容时显示可重试 empty state。
- source 切换会清除旧 source 结果，并重新从第一页请求。

`GalleryDetailNotifier.family` 以 `Gallery` 为参数，在详情页异步 hydrate metadata；详情请求默认不取 page manifest，避免长作品详情打开时解析全部页面。

## 路由

- `/gallery/:source/:gid` 位于 tab `ShellRoute` 之外，详情不会显示底部 tab bar；这也为未来 Reader 全屏 route 保持了正确层级。
- 从列表进入详情时传递 `Gallery` extra，避免多余 DB roundtrip。
- 深链/应用恢复没有 extra 时从 Drift `galleries` 恢复；本机未缓存时显示明确状态，而不是伪造网络数据。

## UI 说明

- iPhone 使用两列 compact grid；中等宽度四列、宽屏五列，未写死设备尺寸。
- 首页提供 E/EX segmented control、搜索栏、刷新、分页操作。
- 详情页目前包含 Hero 封面容器、metadata、标签、阅读/收藏/下载行动位。
- `GalleryCoverPlaceholder` 是稳定尺寸占位，不发起图片请求。下一阶段 ImagePipeline 建立后将替换为真实 cover renderer，避免在 Home UI 中形成第二套图片下载逻辑。

## 测试

- `DiscoveryNotifier` 测试覆盖 cursor 后重复 GalleryKey 去重。
- 应用冒烟测试调整为验证真实首页标题。

## 未完成的 action

详情页的阅读、收藏、下载 action 只保留 UI 位置，尚未绑定业务系统；不能视为功能 parity。下一阶段按既定优先级实现 Tags/Search 体验或开始 ImagePipeline，后者是 Reader 的前置 P0。
