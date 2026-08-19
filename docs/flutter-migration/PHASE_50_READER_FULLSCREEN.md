# Phase D：Reader Fullscreen

## 已实现

- `ReaderFullscreenController` 统一管理进入/退出，重复 enter/exit 去重。
- 进入：解除方向锁定并设置 `SystemUiMode.immersiveSticky`。
- 退出：恢复 Suicang edge-to-edge 基线并解除方向锁定。
- Reader Scaffold 使用 `extendBody` / `extendBodyBehindAppBar`，内容通过 `Positioned.fill` 占满屏幕。
- 外层不再使用 SafeArea 包裹 Reader 内容，避免顶部空白或底部黑色填充。
- Reader 控制栏内部继续使用 SafeArea，防止关闭、页码和 Slider 被刘海/Home Indicator 遮挡。

## 平台说明

Flutter 没有公开读取当前 SystemUiMode 的 API，因此恢复的是 Suicang 应用约定的 edge-to-edge 基线，而不是伪造保存未知系统状态。进入/退出重复调用被 controller 去重。

## 测试

- 全屏进入调用一次 immersiveSticky。
- 重复进入不重复调用。
- 退出调用一次 edgeToEdge。
- 重复退出不重复调用。
- 方向列表在进入和退出都恢复为未锁定。

## 验收

下一次 CI 会验证 Flutter tests、Android ARM64 和 iOS Simulator build。横竖屏与真实系统栏最终需要设备/Simulator screenshots 验收。
