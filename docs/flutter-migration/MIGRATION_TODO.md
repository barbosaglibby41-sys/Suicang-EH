# Flutter Migration Post-Parity TODO

> 迁移功能 parity 与正式真机验收完成后处理。此文件不是当前阶段的阻塞项，按 P0/P1/P2 排序。

## P0：Reader / ImagePipeline / Platform

- [ ] 真正的超长漫画图 tiling / region decode；不要把普通 sprite crop 当作长图 tiling。
- [ ] 评估 Custom ImageProvider 直接持有 `ui.Image`，减少 PNG encode/copy。
- [ ] Reader zoom > 1 时按需请求更高分辨率 variant，并建立 zoom cache eviction。
- [ ] 设备 profile：5000px / 10000px 图片 RSS、frame timing、decode p95、OOM 回归。
- [ ] Reader 可见页精确 visibility tracking，纵向滚动按真实可见页保存进度。
- [ ] 双页 spread：cover parity、LTR/RTL page pairing、横竖屏切换。
- [ ] Reader image priority queue：visible > adjacent > cover > background。
- [ ] GIF/WebP 多帧内存与动画流畅度 profile。
- [ ] `video_player`：iOS/Android 真机、Cookie-protected streaming、后台/旋转/释放验证。
- [ ] iOS Background URLSession download adapter。
- [ ] Android WorkManager download adapter。
- [ ] 原生磁盘空间查询：iOS FileManager/URLResourceValues、Android StatFs。
- [ ] Download orphan reconcile、`.part` 清理和失败文件恢复测试。

## P1：功能 parity

- [ ] Web 登录 bridge 真机验证 HttpOnly Cookie 与取消/旋转恢复。
- [ ] ExHentai `igneous` refresh 真机会话验证与失效重试 fixture。
- [ ] Cloud Favorites 真机读取、分页、加入/移除验证。
- [ ] Comment vote 真机验证；评论编辑/删除不做，除非协议和权限重新确认。
- [ ] EhTagTranslation 远程更新、版本 metadata、校验、内置回退。
- [ ] 预览点击跳转 Reader 指定页。
- [ ] Torrent 分享/保存/外部下载 handler 真机验证。
- [ ] Offline file migration：文件复制、checksum、manifest reconcile。
- [ ] SwiftData/UserDefaults native export bridge；保留旧 App 数据直到用户验证完成。
- [ ] 迁移 bundle 导出 UI；继续禁止 Cookie/Keychain/Token 导出。
- [ ] Gallery detail comment pagination。

## P1：UI / Accessibility

- [ ] iPad NavigationSplitView 等价三栏 detail 布局。
- [ ] Android 平板 adaptive rail / list / detail 布局。
- [ ] Dynamic Type 大字体 golden/widget tests。
- [ ] VoiceOver/TalkBack semantics、focus order、state announcements。
- [ ] 所有交互控件最小 44x44 触控目标检查。
- [ ] Light/Dark、高对比度、Reduce Motion、文字缩放 golden tests。
- [ ] Hero、Reader controls、Bottom Sheet accessibility labels。

## P2：质量与发布

- [ ] 固化并提交 `ios/`、`android/` host scaffold，禁止 CI 每次漂移生成。
- [ ] CI 增加 iOS 真机构建/签名配置（仅在证书安全配置完成后）。
- [ ] Flutter release APK/IPA 正式产物安装回归。
- [ ] Widget/golden/integration test matrix：手机竖横屏、iPad、Android 平板。
- [ ] 性能基准 artifact：首屏、搜索、详情、Reader 翻页、下载恢复。
- [ ] Crash/error diagnostics 脱敏审计。
- [ ] 依赖升级与 Flutter stable 兼容性定期检查。
- [ ] SwiftUI 删除门禁：功能矩阵、迁移数据回滚、真机 beta 全部通过后才执行。

## 不做

- [ ] 不实现评论编辑/删除。
- [ ] 不把 Cookie/Keychain/Token 放入迁移包、日志或普通数据库。
- [x] 当前发布门禁允许 iOS Simulator build 作为未签名 IPA 的构建验收；真机签名/安装不作为本阶段阻塞项。
