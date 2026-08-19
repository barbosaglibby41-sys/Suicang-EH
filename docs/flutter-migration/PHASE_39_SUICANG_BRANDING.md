# Phase 39：Suicang EH Branding + 0.1.1

## 品牌

Flutter 应用对外品牌迁移为：

```text
Suicang EH
```

- MaterialApp title：Suicang EH
- Home masthead：SUICANG EH
- Dart package：`suicang_eh`
- iOS Bundle ID：`com.suicang.eh`
- iOS display name：Suicang EH
- Android application label：Suicang EH
- Release artifact 名称：`suicang-eh-*`

## 兼容性

不改动以下旧 key/path：

- `taro_eh.sqlite`
- SharedPreferences `taro.eh.*`
- Secure Storage `taro_eh.auth.cookies.v1`
- image cache directory `taro_eh`

原因：这些是本机用户数据兼容键。强行更名会使 0.1.1 无法读取前一 Flutter 版本的阅读进度、设置、Cookie 或数据库。

## 图标

用户提供的 Suicang EH artwork 保存为：

```text
assets/branding/suicang_eh_icon_1024.png
```

`flutter_launcher_icons` 在 Android/iOS host 生成后生产平台 icon。CI/正式 Release workflow 在构建 host 后调用图标生成。

## 版本

```text
0.1.1+2
```

后续正式 tag：`v0.1.1-suicang-stable`。
