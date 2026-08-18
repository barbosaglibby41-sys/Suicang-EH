# Phase 17：Reader Hardening

## 修复与增强

- `ImagePipeline` 现在识别 `file://` request，直接 `File.fromUri().readAsBytes()`，不走 Dio、Cookie、disk cache 或网络。OfflinePageSource 因此能真正使用同一 ReaderScreen / Pipeline 显示离线页面。
- 横向 Reader 改为 StatefulWidget 持有长期 `PageController`。控制栏、进度、缩放状态更新不再创建新的 controller 并跳回 initial page。
- Engine 的显式 `goTo`（slider 跳页/进度恢复）会同步 PageController；用户滑动会反向同步 Engine，不产生循环跳转。
- Reader controls 新增：
  - LTR/RTL 切换
  - Slider 跳页
  - 双击 1x/2x zoom
  - 现有 horizontal/vertical 与 contain/cover 继续保留
- FutureBuilder 先处理 error，再处理 loading，失败页面不再永久显示 spinner。

## 已知限制

- RTL 当前通过 PageView reverse 改变横向顺序；双页 spread 尚未实现。
- Vertical mode 尚未根据 scroll visibility 精确更新 reading index，仍由已加载/交互页驱动；需要后续 Sliver visibility hardening。
- `Transform.scale` 是基础 double-tap zoom；InteractiveViewer 手势缩放不会回写 Engine zoom state。
- Reader image decode 仍以 byte cache + Image.memory 进行，超大图 codec-level downsample/tiling 是下一个性能专项。

## 测试

新增 file URI pipeline test：验证离线文件读取不走网络 transport。
