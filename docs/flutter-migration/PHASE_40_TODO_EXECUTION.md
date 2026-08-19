# Phase 40：Post-Parity TODO Execution Slice

## 已完成的待办切片

- Preview strip 点击跳转 Reader 指定页：`?page=N`。
- Preview tile 提供 button semantics、页码 label 和“从此页开始阅读” hint。
- Reader route 读取 query page，并优先于保存的阅读进度作为起始位置。
- 继续保持预览 sprite 复用 ImagePipeline，不新增网络请求实现。

## 本阶段不伪称完成

迁移 TODO 中的超长图 tiling、Custom ImageProvider、真机媒体性能、后台下载、真机 Cookie/Cloud Favorites 等需要平台/设备 profile 的项目仍保持未完成状态。

## Suicang branding

上一阶段已写入品牌 asset、版本 0.1.1、包名和 CI 发布工作流；正式 0.1.1 Release 需在下一轮 CI 全绿且 iOS/Android 产物通过结构检查后发布。
