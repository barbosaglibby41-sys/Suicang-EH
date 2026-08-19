# Phase 47：Enhanced Random Feed + Follows Tab + China Time

## 随机探索

随机发现从一次性结果升级为 session feed：

- 新随机会话：随机按钮显示“换一批”，清空旧结果后从新随机集合开始。
- 无限滚动：触底继续请求随机批次。
- 按 GalleryKey 去重。
- 维护 randomRound、结果数和 randomExhausted。
- 空批次时结束当前会话，避免无意义无限请求。
- 下拉刷新随机页会创建全新随机会话。

## 关注页

Library 现在显示“关注”第四个 Tab，嵌入 FollowedCreatorsScreen。进入 Tab 后关注列表首次加载完成会自动请求每个作者/发布者最新结果一次。

## 发布时间

- 两天内：相对时间。
- 超过两天：`yyyy-MM-dd HH:mm` 中国时间格式。
- 详情 Tooltip：完整中国时间并标注“中国时间”。

相对时间按 UTC 差值计算（时区不影响 elapsed duration），绝对时间显式转换为 UTC+8。
