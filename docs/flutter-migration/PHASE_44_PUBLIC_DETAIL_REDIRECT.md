# Phase 44：Prefer Public Detail Redirect

## 功能

新增站点偏好：

```text
优先重定向至表站
```

默认开启。仅当 Gallery 原始来源是 ExHentai 且详情 URL host 是 `exhentai.org` 时生效：

```text
https://exhentai.org/g/<gid>/<token>/
  -> https://e-hentai.org/g/<gid>/<token>/
```

路径、token 和 query 保持不变。

## 回退

表站详情请求/解析失败时自动回退原始 ExHentai URL。不会改变：

- 当前默认站点来源
- Cookie 存储
- Gallery stable key (`source:gid`)
- 收藏、历史、阅读进度或下载归属

## 设置

Settings 站点来源区域新增 Switch，并由 SharedPreferences 持久化：

```text
taro.eh.site.prefer_public_detail_redirect
```

## 架构

GalleryRepository 接收纯 bool 策略参数；Provider composition root 从 SitePreferences 注入。data repository 不直接 import Riverpod/Settings Provider。
