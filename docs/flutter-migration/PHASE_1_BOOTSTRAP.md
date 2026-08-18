# Flutter 工程初始化（Phase 1）

本目录是 TaroEH 的 Flutter 迁移根工程。原生 SwiftUI 代码仍保留在 `TaroEH/`，且尚未删除或替换。

## 已建立

- `lib/app`：启动错误边界、Riverpod composition root、GoRouter shell、亮暗主题。
- `lib/features`：发现、书架、下载、设置的 presentation 路由占位；不含业务伪实现。
- iPhone 底部导航与宽屏/iPad NavigationRail 自适应壳。
- `test/app_smoke_test.dart`：应用启动冒烟测试。
- `.github/workflows/flutter-ci.yml`：格式化、分析、测试、Android debug APK artifact。

## 本地运行（拥有 Flutter SDK 时）

```sh
flutter pub get
flutter create --platforms=android,ios --project-name=taro_eh_flutter .
flutter test
flutter analyze
flutter run
```

`flutter create` 只生成 Flutter 平台宿主目录；执行前确认不会覆盖原 `TaroEH/` Swift 源码或 `project.yml`。CI 目前仅生成 Android 平台骨架以构建 debug APK；iOS runner 将在接入 iOS 宿主与安全存储/WebView bridge 后加入。

## 下一阶段

建立不可变 domain primitives、Repository contracts 与 Drift schema v1，再接入认证与网络。禁止在 Widget 内直接使用 Dio、文件系统或数据库。
